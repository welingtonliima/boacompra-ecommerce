import json
import logging
import os
import random
import unicodedata
from decimal import ROUND_HALF_UP, Decimal
from pathlib import Path
from typing import Optional

import pandas as pd
from dotenv import load_dotenv
from faker import Faker
from sqlalchemy import create_engine, text

# Carrega variáveis do .env
load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_NAME = os.getenv("DB_NAME")

# Monta a URL de conexão
DATABASE_URL = (
    f"mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# ========== CONFIGURAÇÕES ==========
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

fake = Faker("pt_BR")
engine = create_engine(
    "mysql+mysqlconnector://boacompra_adm:K&dTsfiI2],0K2/!@mysql:3306/boacompra_adm"
)
ID_USUARIO_PADRAO = 1
CSV_BASE_PATH = Path("csv")


# ========== FUNÇÕES AUXILIARES ==========
def tabela_esta_vazia(nome_tabela: str) -> bool:
    with engine.connect() as conn:
        return conn.execute(text(f"SELECT COUNT(*) FROM {nome_tabela}")).scalar() == 0


def inserir_dataframe(df: pd.DataFrame, tabela: str) -> None:
    try:
        df.to_sql(tabela, con=engine, if_exists="append", index=False)
        logger.info(f"{len(df)} registros inseridos na tabela {tabela}.")
    except Exception as e:
        logger.error(f"Erro ao inserir dados na tabela {tabela}: {e}")


def remover_acentos(texto: str) -> str:
    texto_normalizado = unicodedata.normalize("NFKD", texto)
    texto_sem_acentos = "".join(
        c for c in texto_normalizado if not unicodedata.combining(c)
    )
    return texto_sem_acentos


# ========== INSERÇÕES ==========
def inserir_unidade_federativa():
    if not tabela_esta_vazia("tb_unidade_federativa"):
        logger.info("tb_unidade_federativa já contém dados.")
        return
    df = pd.read_csv(CSV_BASE_PATH / "states.csv")
    df["id_usuario_criacao"] = ID_USUARIO_PADRAO
    df["id_usuario_atualizacao"] = ID_USUARIO_PADRAO
    inserir_dataframe(df, "tb_unidade_federativa")


def inserir_municipio():
    if not tabela_esta_vazia("tb_municipio"):
        logger.info("tb_municipio já contém dados.")
        return

    df_municipios = pd.read_csv(CSV_BASE_PATH / "cities.csv")
    df_ufs = pd.read_sql(
        "SELECT id_unidade_federativa, sg_unidade_federativa FROM tb_unidade_federativa",
        engine,
    )

    df_merged = df_municipios.merge(df_ufs, on="sg_unidade_federativa", how="left")

    if df_merged["id_unidade_federativa"].isnull().any():
        siglas_invalidas = df_merged.loc[
            df_merged["id_unidade_federativa"].isnull(), "sg_unidade_federativa"
        ].unique()
        logger.error(f"Siglas inválidas: {siglas_invalidas}")
        return

    df_merged["id_usuario_criacao"] = ID_USUARIO_PADRAO
    df_merged["id_usuario_atualizacao"] = ID_USUARIO_PADRAO

    colunas = [
        "id_unidade_federativa",
        "co_municipio_ibge",
        "no_municipio",
        "in_ativo",
        "id_usuario_criacao",
        "id_usuario_atualizacao",
    ]

    inserir_dataframe(df_merged[colunas], "tb_municipio")


def inserir_cliente(qtd: int = 10000) -> None:
    if not tabela_esta_vazia("tb_cliente"):
        logger.info("tb_cliente já contém dados.")
        return

    try:
        cpfs = set()
        while len(cpfs) < qtd:
            novo_cpf = fake.cpf().replace(".", "").replace("-", "")
            cpfs.add(novo_cpf)

        clientes = []
        for cpf in cpfs:  # iterar diretamente no set gerado
            clientes.append(
                {
                    "no_cliente": fake.name(),
                    "nu_cpf": cpf,
                    "dt_nascimento": fake.date_of_birth(minimum_age=18, maximum_age=90),
                    "in_ativo": random.choice([0, 1]),
                    "id_usuario_criacao": ID_USUARIO_PADRAO,
                    "id_usuario_atualizacao": ID_USUARIO_PADRAO,
                }
            )

        df = pd.DataFrame(clientes)
        inserir_dataframe(df, "tb_cliente")
    except Exception as e:
        logger.error(f"Erro ao inserir clientes: {e}")


def inserir_cliente_endereco(qtd: int = 10000) -> None:
    if not tabela_esta_vazia("tb_cliente_endereco"):
        logger.info("tb_cliente_endereco já contém dados.")
        return

    try:
        with engine.connect() as conn:
            clientes_ids = [
                row[0]
                for row in conn.execute(
                    text("SELECT id_cliente FROM tb_cliente")
                ).fetchall()
            ]
            municipios_ids = [
                row[0]
                for row in conn.execute(
                    text("SELECT id_municipio FROM tb_municipio")
                ).fetchall()
            ]

        qtd = min(qtd, len(clientes_ids))
        clientes_selecionados = random.sample(clientes_ids, qtd)

        registros = []
        for cliente_id in clientes_selecionados:
            municipio_id = random.choice(municipios_ids)
            registros.append(
                {
                    "id_cliente": cliente_id,
                    "id_municipio": municipio_id,
                    "no_logradouro": fake.street_name(),
                    "nu_endereco": str(random.randint(1, 9999)),
                    "ds_complemento": "SEM COMPLEMENTO",
                    "no_bairro": fake.city_suffix(),
                    "nu_cep": fake.postcode().replace("-", "")[:8],
                    "id_usuario_criacao": ID_USUARIO_PADRAO,
                    "id_usuario_atualizacao": ID_USUARIO_PADRAO,
                }
            )

        df = pd.DataFrame(registros)
        inserir_dataframe(df, "tb_cliente_endereco")
    except Exception as e:
        logger.error(f"Erro ao inserir endereços de clientes: {e}")


def inserir_cliente_email(max_emails_por_cliente: int = 3) -> None:
    if not tabela_esta_vazia("tb_cliente_email"):
        logger.info("tb_cliente_email já contém dados.")
        return

    try:
        with engine.connect() as conn:
            clientes_ids = [
                row[0]
                for row in conn.execute(
                    text("SELECT id_cliente FROM tb_cliente")
                ).fetchall()
            ]

        registros = []
        for cliente_id in clientes_ids:
            qtd_emails = random.randint(1, max_emails_por_cliente)
            emails_gerados = set()

            for i in range(qtd_emails):
                while True:
                    email = fake.email()
                    if email not in emails_gerados:
                        emails_gerados.add(email)
                        break

                registros.append(
                    {
                        "id_cliente": cliente_id,
                        "tx_email": email,
                        "in_principal": 1 if i == 0 else 0,
                        "id_usuario_criacao": ID_USUARIO_PADRAO,
                        "id_usuario_atualizacao": ID_USUARIO_PADRAO,
                    }
                )

        df = pd.DataFrame(registros)
        inserir_dataframe(df, "tb_cliente_email")

    except Exception as e:
        logger.error(f"Erro ao inserir emails de clientes: {e}")


def inserir_cliente_contato(max_contatos_por_cliente: int = 3) -> None:
    if not tabela_esta_vazia("tb_cliente_contato"):
        logger.info("tb_cliente_contato já contém dados.")
        return

    try:
        with engine.connect() as conn:
            clientes_ids = [
                row[0]
                for row in conn.execute(
                    text("SELECT id_cliente FROM tb_cliente")
                ).fetchall()
            ]

        registros = []
        tipos_contato_validos = [
            1,
            2,
            3,
            4,
        ]  # 1-Celular, 2-Fixo, 3-Comercial, 4-Whatsapp

        for cliente_id in clientes_ids:
            qtd_contatos = random.randint(1, max_contatos_por_cliente)
            contatos_gerados = set()

            for i in range(qtd_contatos):
                while True:
                    ddd = random.randint(11, 99)
                    telefone_numero = fake.msisdn()[-8:]
                    tipo = random.choice(tipos_contato_validos)
                    chave_unica = (cliente_id, ddd, telefone_numero, tipo)
                    if chave_unica not in contatos_gerados:
                        contatos_gerados.add(chave_unica)
                        break

                registros.append(
                    {
                        "id_cliente": cliente_id,
                        "nu_ddd": ddd,
                        "nu_telefone": telefone_numero,
                        "tp_contato": tipo,
                        "in_principal": 1 if i == 0 else 0,
                        "id_usuario_criacao": ID_USUARIO_PADRAO,
                        "id_usuario_atualizacao": ID_USUARIO_PADRAO,
                    }
                )

        df = pd.DataFrame(registros)
        inserir_dataframe(df, "tb_cliente_contato")

    except Exception as e:
        logger.error(f"Erro ao inserir contatos de clientes: {e}")


def inserir_produto_categoria() -> None:
    categorias = [
        "Eletrônicos",
        "Roupas",
        "Brinquedos",
        "Móveis",
        "Livros",
        "Beleza",
        "Esportes",
        "Alimentos",
        "Informática",
        "Automotivo",
        "Calçados",
        "Joias",
        "Saúde",
        "Casa e Jardim",
        "Telefonia",
        "Ferramentas",
        "Relógios",
        "Bebês",
        "Pet Shop",
        "Papelaria",
    ]
    if not tabela_esta_vazia("tb_produto_categoria"):
        logger.info("tb_produto_categoria já contém dados.")
        return

    try:
        registros = []
        for nome_categoria in categorias:
            nome_sem_acentos = remover_acentos(nome_categoria).upper()
            registros.append(
                {
                    "no_produto_categoria": nome_sem_acentos,
                    "in_ativo": 1,
                    "id_usuario_criacao": ID_USUARIO_PADRAO,
                    "id_usuario_atualizacao": ID_USUARIO_PADRAO,
                }
            )

        df = pd.DataFrame(registros)
        inserir_dataframe(df, "tb_produto_categoria")

    except Exception as e:
        logger.error(f"Erro ao inserir categorias fixas: {e}")


def inserir_produto_medida() -> None:
    unidades = [
        {"no_unidade_medida": "Unidade", "sg_unidade_medida": "UN"},
        {"no_unidade_medida": "Quilograma", "sg_unidade_medida": "KG"},
        {"no_unidade_medida": "Grama", "sg_unidade_medida": "G"},
        {"no_unidade_medida": "Litro", "sg_unidade_medida": "L"},
        {"no_unidade_medida": "Mililitro", "sg_unidade_medida": "ML"},
        {"no_unidade_medida": "Metro", "sg_unidade_medida": "M"},
        {"no_unidade_medida": "Centímetro", "sg_unidade_medida": "CM"},
        {"no_unidade_medida": "Milímetro", "sg_unidade_medida": "MM"},
        {"no_unidade_medida": "Pacote", "sg_unidade_medida": "PC"},
        {"no_unidade_medida": "Caixa", "sg_unidade_medida": "CX"},
        {"no_unidade_medida": "Dúzia", "sg_unidade_medida": "DZ"},
        {"no_unidade_medida": "Par", "sg_unidade_medida": "PAR"},
        {"no_unidade_medida": "Tonelada", "sg_unidade_medida": "T"},
        {"no_unidade_medida": "Hora", "sg_unidade_medida": "H"},
        {"no_unidade_medida": "Dia", "sg_unidade_medida": "D"},
        {"no_unidade_medida": "Pacote Pequeno", "sg_unidade_medida": "PCP"},
        {"no_unidade_medida": "Pacote Grande", "sg_unidade_medida": "PCG"},
        {"no_unidade_medida": "Galão", "sg_unidade_medida": "GL"},
        {"no_unidade_medida": "Litro Estendido", "sg_unidade_medida": "LE"},
        {"no_unidade_medida": "Unidade Comercial", "sg_unidade_medida": "UC"},
    ]

    if not tabela_esta_vazia("tb_produto_unidade_medida"):
        logger.info("tb_produto_unidade_medida já contém dados.")
        return

    try:
        registros = []
        for unidade in unidades:
            no_unidade_medida = remover_acentos(unidade["no_unidade_medida"]).upper()
            sg_unidade_medida = unidade["sg_unidade_medida"].upper()
            registros.append(
                {
                    "no_unidade_medida": no_unidade_medida,
                    "sg_unidade_medida": sg_unidade_medida,
                    "in_ativo": 1,
                    "id_usuario_criacao": ID_USUARIO_PADRAO,
                    "id_usuario_atualizacao": ID_USUARIO_PADRAO,
                }
            )

        df = pd.DataFrame(registros)
        inserir_dataframe(df, "tb_produto_unidade_medida")
    except Exception as e:
        logger.error(f"Erro ao inserir unidades de medida: {e}")


def inserir_produto(max_por_categoria: int = 50) -> None:
    if not tabela_esta_vazia("tb_produto"):
        logger.info("tb_produto já contém dados.")
        return

    try:
        with engine.connect() as conn:
            categorias = [
                row[0]
                for row in conn.execute(
                    text("SELECT id_produto_categoria FROM tb_produto_categoria")
                ).fetchall()
            ]
            unidades_medida = [
                row[0]
                for row in conn.execute(
                    text(
                        "SELECT id_produto_unidade_medida FROM tb_produto_unidade_medida"
                    )
                ).fetchall()
            ]

            if not categorias or not unidades_medida:
                logger.error(
                    "Categorias ou unidades de medida não encontradas. Insira-as antes de inserir produtos."
                )
                return

        produtos = []
        nomes_usados = set()

        for categoria_id in categorias:
            for _ in range(max_por_categoria):
                # Garante nome único
                while True:
                    nome_produto = fake.unique.catch_phrase()[:150]  # Limita tamanho
                    if nome_produto not in nomes_usados:
                        nomes_usados.add(nome_produto)
                        break

                produtos.append(
                    {
                        "id_produto_categoria": categoria_id,
                        "id_produto_unidade_medida": random.choice(unidades_medida),
                        "no_produto": nome_produto.upper(),
                        "ds_produto": fake.text(max_nb_chars=500),
                        "vl_produto_unitario": round(random.uniform(10.0, 1000.0), 2),
                        "in_ativo": 1,
                        "id_usuario_criacao": ID_USUARIO_PADRAO,
                        "id_usuario_atualizacao": ID_USUARIO_PADRAO,
                    }
                )

        df = pd.DataFrame(produtos)
        inserir_dataframe(df, "tb_produto")
    except Exception as e:
        logger.error(f"Erro ao inserir produtos: {e}")


def inserir_pedido(qtd: int = 5000) -> None:
    if not tabela_esta_vazia("tb_pedido"):
        logger.info("tb_pedido já contém dados.")
        return

    with engine.connect() as conn:
        clientes = [
            row[0] for row in conn.execute(text("SELECT id_cliente FROM tb_cliente"))
        ]
        situacoes = [
            row[0]
            for row in conn.execute(
                text("SELECT co_pedido_situacao FROM tb_pedido_situacao")
            )
        ]

    pedidos = []
    for _ in range(qtd):
        pedido = {
            "id_cliente": random.choice(clientes),
            "co_pedido_situacao": random.choice(situacoes),
            "dt_pedido": fake.date_between(start_date="-1y", end_date="today"),
            "vl_pedido_total": 0,
            "tx_observacao": fake.text(100) if random.random() > 0.5 else None,
            "id_usuario_criacao": ID_USUARIO_PADRAO,
            "id_usuario_atualizacao": ID_USUARIO_PADRAO,
        }
        pedidos.append(pedido)

    df = pd.DataFrame(pedidos)
    inserir_dataframe(df, "tb_pedido")


def inserir_pedido_item(max_itens: int = 20) -> None:
    if not tabela_esta_vazia("tb_pedido_item"):
        logger.info("tb_pedido_item já contém dados.")
        return

    try:
        with engine.connect() as conn:
            pedidos = [
                row[0] for row in conn.execute(text("SELECT id_pedido FROM tb_pedido"))
            ]
            produtos = conn.execute(
                text("SELECT id_produto, vl_produto_unitario FROM tb_produto")
            ).fetchall()

        itens = []
        for pedido_id in pedidos:
            qtd_itens = random.randint(1, min(max_itens, len(produtos)))
            produtos_sorteados = random.sample(produtos, qtd_itens)  # sem repetição

            for prod in produtos_sorteados:
                qt = random.randint(1, 50)
                vl_unitario = prod.vl_produto_unitario  # já é Decimal
                qt_decimal = Decimal(str(qt))
                max_desconto = (vl_unitario * qt_decimal * Decimal("0.3")).quantize(
                    Decimal("0.01"), rounding=ROUND_HALF_UP
                )
                desconto_decimal = Decimal(
                    str(random.uniform(0, float(max_desconto)))
                ).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
                total = (vl_unitario * qt_decimal - desconto_decimal).quantize(
                    Decimal("0.01"), rounding=ROUND_HALF_UP
                )

                item = {
                    "id_pedido": pedido_id,
                    "id_produto": prod.id_produto,
                    "qt_item": qt,
                    "vl_unitario": vl_unitario,
                    "vl_desconto": desconto_decimal,
                    "vl_item_total": total,
                    "id_usuario_criacao": ID_USUARIO_PADRAO,
                    "id_usuario_atualizacao": ID_USUARIO_PADRAO,
                }
                itens.append(item)

        df = pd.DataFrame(itens)
        inserir_dataframe(df, "tb_pedido_item")

        with engine.begin() as conn:
            conn.execute(
                text(
                    """
                UPDATE tb_pedido p
                JOIN (
                    SELECT id_pedido, SUM(vl_item_total) AS total
                    FROM tb_pedido_item
                    GROUP BY id_pedido
                ) t ON p.id_pedido = t.id_pedido
                SET p.vl_pedido_total = t.total
            """
                )
            )
            logger.info("Total dos pedidos atualizados com sucesso.")

    except Exception as e:
        logger.error(f"Erro ao inserir itens de pedido ou atualizar total: {e}")


# ========== TESTE ==========
def consultar_relatorio_venda_periodo(
    data_inicio: str = "2025-01-01",
    data_fim: str = "2025-06-01",
    categoria: str = "ELETRONICOS",
) -> Optional[dict]:
    raw_conn = None
    cursor = None
    try:
        raw_conn = engine.raw_connection()
        cursor = raw_conn.cursor()

        params = [data_inicio, data_fim, categoria, None]
        resultado = cursor.callproc("prc_relatorio_venda_periodo", params)

        relatorio_str = resultado[-1]

        if relatorio_str:
            relatorio_json = json.loads(relatorio_str)
            logger.info(
                "Relatório de venda por período consultado com sucesso:\n"
                + json.dumps(relatorio_json, indent=4, ensure_ascii=False)
            )
            return relatorio_json
        else:
            logger.warning("Procedure retornou resultado vazio.")
            return None

    except Exception as e:
        logger.error(f"Erro ao consultar relatório de venda por período: {e}")
        return None


def consultar_relatorio_pedido_cliente_valor_minino(
    data_inicio: str = "2025-01-01",
    data_fim: str = "2025-06-01",
    situacao_pedido: str = "CONCLUIDO",
    valor_minimo: float = 10000.00,
    valor_limit: int = 20,
    nu_pagina: int = 1,
) -> Optional[dict]:
    raw_conn = None
    cursor = None
    try:
        raw_conn = engine.raw_connection()
        cursor = raw_conn.cursor()

        params = [
            data_inicio,
            data_fim,
            situacao_pedido,
            valor_minimo,
            valor_limit,
            nu_pagina,
            None,
        ]
        resultado = cursor.callproc("prc_relatorio_pedido_cliente_valor_minino", params)

        relatorio_str = resultado[-1]

        if relatorio_str:
            relatorio_json = json.loads(relatorio_str)
            logger.info(
                "Relatório de pedido por cliente (valor mínimo) consultado com sucesso:\n"
                + json.dumps(relatorio_json, indent=4, ensure_ascii=False)
            )
            return relatorio_json
        else:
            logger.warning(
                "Procedure prc_relatorio_pedido_cliente_valor_minino retornou resultado vazio."
            )
            return None

    except Exception as e:
        logger.error(
            f"Erro ao consultar relatório de pedido por cliente (valor mínimo): {e}"
        )
        return None

    finally:
        if cursor is not None:
            cursor.close()
        if raw_conn is not None:
            raw_conn.close()


# ========== EXECUÇÃO PRINCIPAL ==========
def main():
    inserir_unidade_federativa()
    inserir_municipio()
    inserir_cliente()
    inserir_cliente_endereco()
    inserir_cliente_email()
    inserir_cliente_contato()
    inserir_produto_categoria()
    inserir_produto_medida()
    inserir_produto()
    inserir_pedido()
    inserir_pedido_item()

    relatorio_venda_periodo = consultar_relatorio_venda_periodo()
    relatorio_pedido = consultar_relatorio_pedido_cliente_valor_minino()


if __name__ == "__main__":
    main()
