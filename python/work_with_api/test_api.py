import requests
api_url = "https://jsonplaceholder.typicode.com/todos/3"
response = requests.get(api_url)
response.json()
