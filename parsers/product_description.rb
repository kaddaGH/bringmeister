data = JSON.parse(content)
products_details = page['vars']['product_details']
description = data['data']['product']['content']['description']

availability = (data['data']['product']['isAvailable']==true)?"1":""
products_details[:PRODUCT_DESCRIPTION]=description
products_details[:IS_AVAILABLE] = availability


outputs<<products_details

