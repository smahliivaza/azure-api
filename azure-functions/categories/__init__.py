from azure.cosmos import exceptions, CosmosClient, PartitionKey
import azure.functions as func
import logging
import json
import os

endpoint = os.environ['COSMOSDB_ENDPOINTURI']
key = os.environ['COSMOSDB_PRIMARYKEY']
database_name = 'library'
container_name = 'categories'

client = CosmosClient(endpoint, key)
database = client.create_database_if_not_exists(id=database_name)

container = database.create_container_if_not_exists(
    id=container_name,
    partition_key=PartitionKey(path="/Category"),
    offer_throughput=100
)


def statistics():
    query = "SELECT categories.Category, ARRAY_LENGTH(categories.Books) AS Books FROM categories " \
            "ORDER BY categories.Category"

    statistic = list(container.query_items(
        query=query,
        enable_cross_partition_query=True
    ))

    return json.dumps(statistic)


def get_category(category_name):
    query = f"SELECT categories.Books FROM categories WHERE categories.Category = '{category_name}'"

    try:
        result = list(container.query_items(
            query=query,
            enable_cross_partition_query=True
        ))
        return json.dumps(result[0])
    except Exception:
        logging.info(Exception)
        file = json.load(open('openapi.json', 'r'))
        return json.dumps(file)


def show_categories():
    query = "SELECT VALUE categories.Category FROM categories ORDER BY categories.Category"

    categories_list = list(container.query_items(
        query=query,
        enable_cross_partition_query=True
    ))

    return json.dumps(categories_list)


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    route = req.route_params.get('route')

    if route == 'statistics':
        return func.HttpResponse(statistics(), status_code=200)
    elif route:
        return func.HttpResponse(get_category(route), status_code=200)
    else:
        return func.HttpResponse(show_categories(), status_code=200)
