curl --location --request POST 'https://d5dg1j9kt695d30blp03.apigw.yandexcloud.net/generate_report' \
 --header 'X-Nickname: Samogonn' \
 --header 'X-Cohort: 30' \
 --header 'X-Project: True' \
 --header 'X-API-KEY: 5f55e6c0-e9e5-4a9c-b313-63c01fc31460' \
 --data-raw ''

 curl --location --request GET 'https://d5dg1j9kt695d30blp03.apigw.yandexcloud.net/get_report?task_id=MjAyNC0xMC0wOFQwNjo0MzozNwlTYW1vZ29ubg==' \
 --header 'X-Nickname: Samogonn' \
 --header 'X-Cohort: 30' \
 --header 'X-Project: True' \
 --header 'X-API-KEY: 5f55e6c0-e9e5-4a9c-b313-63c01fc31460'

https://storage.yandexcloud.net/s3-sprint3/cohort_30/Samogonn/project/TWpBeU5DMHhNQzB3T0ZRd05qbzBNem96TndsVFlXMXZaMjl1Ymc9PQ==/customer_research.csv

curl --location --request GET 'https://d5dg1j9kt695d30blp03.apigw.yandexcloud.net/get_increment?report_id=TWpBeU5DMHhNQzB3T0ZRd05qbzBNem96TndsVFlXMXZaMjl1Ymc9PQ==&date=2024-09-30T00:00:00' \
 --header 'X-Nickname: Samogonn' \
 --header 'X-Cohort: 30' \
 --header 'X-Project: True' \
 --header 'X-API-KEY: 5f55e6c0-e9e5-4a9c-b313-63c01fc31460'