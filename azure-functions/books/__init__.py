from azure.cosmos import CosmosClient, PartitionKey
import azure.functions as func
import logging
import json
import os

endpoint = os.environ['COSMOSDB_ENDPOINTURI']
key = os.environ['COSMOSDB_PRIMARYKEY']
database_name = 'library'
container_name = 'books'

client = CosmosClient(endpoint, key)
database = client.create_database_if_not_exists(id=database_name)

container = database.create_container_if_not_exists(
    id=container_name,
    partition_key=PartitionKey(path="/id"),
    offer_throughput=100
)

file = json.load(open('openapi.json', 'r'))


def get_highest_price():
    highest_price_query = "SELECT VALUE MAX(books.Price) FROM books"
    highest_price = list(container.query_items(
        query=highest_price_query,
        enable_cross_partition_query=True
    ))

    return json.dumps(highest_price[0])


def priciest():
    matching_query = f"SELECT books.id, books.Title, books.Category, books.Price, books.Stock FROM books " \
                     f"WHERE books.Price = {get_highest_price()}"
    matching_books = list(container.query_items(
        query=matching_query,
        enable_cross_partition_query=True
    ))

    return json.dumps(matching_books)


def get_book(book_id):
    query = f"SELECT books.id, books.Title, books.Category, books.Price, books.Stock FROM books " \
            f"WHERE books.id = '{book_id}'"

    try:
        result = list(container.query_items(
            query=query,
            enable_cross_partition_query=True
        ))
        return json.dumps(result[0])
    except Exception:
        logging.info(Exception)
        return json.dumps(file)


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    route = req.route_params.get('route')

    if route == 'priciest':
        return func.HttpResponse(priciest(), status_code=200)
    elif route:
        return func.HttpResponse(get_book(route), status_code=200)
    else:
        return func.HttpResponse(json.dumps(file), status_code=200)
