from statistics import mean 

def calculate_average(list_prices):
    return mean(list_prices)

prices = [7200, 8500, 15000, 30000]
avg = calculate_average(prices)
print(avg)