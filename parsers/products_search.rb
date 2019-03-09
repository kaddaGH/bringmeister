data = JSON.parse(content)

scrape_url_nbr_products = data['totalElements'].to_i
offset = data['offset'].to_i
page_size = data['length'].to_i
products = data['products']

# if ot's first page , generate pagination
if offset == 0 and scrape_url_nbr_products > offset
  nbr_products_pg1 = products.length
  step_page = 1
  offset = offset+page_size
  while offset <= scrape_url_nbr_products

    pages << {
        page_type: 'products_search',
        method: 'GET',
        url: page['url'].gsub(/offset=0/, "page=#{offset}"),
        vars: {
            'input_type' => page['vars']['input_type'],
            'search_term' => page['vars']['search_term'],
            'page' => step_page,
            'nbr_products_pg1' => nbr_products_pg1
        }
    }

    step_page = step_page + 1


  end
elsif offset == 1 and scrape_url_nbr_products<=offset
  nbr_products_pg1 = products.length
else
  nbr_products_pg1 = page['vars']['nbr_products_pg1']
end


products.each_with_index do |product, i|

  promotion = product['prices']['specialDiscount']>0 ? "-"+product['prices']['specialDiscount']+"%":""

  price = product['prices']['specialPrice']
  if price.nil?
    price = product['prices']['price']

  end
  brand = product['brand']

  size_info = product['packing']
  [
      /(\d*[\.,]?\d+)\s?([Ff][Ll]\.?\s?[Oo][Zz])/,
      /(\d*[\.,]?\d+)\s?([Oo][Zz])/,
      /(\d*[\.,]?\d+)\s?([Ff][Oo])/,
      /(\d*[\.,]?\d+)\s?([Ee][Aa])/,
      /(\d*[\.,]?\d+)\s?([Ff][Zz])/,
      /(\d*[\.,]?\d+)\s?(Fluid Ounces?)/,
      /(\d*[\.,]?\d+)\s?([Oo]unce)/,
      /(\d*[\.,]?\d+)\s?([Mm][Ll])/,
      /(\d*[\.,]?\d+)\s?([Ll])/,
      /(\d*[\.,]?\d+)\s?([Kk][Gg])/,
      /(\d*[\.,]?\d+)\s?([Gg])/,
      /(\d*[\.,]?\d+)\s?([Ll]itre)/,
      /(\d*[\.,]?\d+)\s?([Ss]ervings)/,
      /(\d*[\.,]?\d+)\s?([Pp]acket\(?s?\)?)/,
      /(\d*[\.,]?\d+)\s?([Cc]apsules)/,
      /(\d*[\.,]?\d+)\s?([Tt]ablets)/,
      /(\d*[\.,]?\d+)\s?([Tt]ubes)/,
      /(\d*[\.,]?\d+)\s?([Cc]hews)/


  ].find {|regexp| size_info =~ regexp}
  uom = $2
  item_size = $1

  match = [
      /(\d+)\s?[xX]/,
      /Pack of (\d+)/,
      /Box of (\d+)/,
      /Case of (\d+)/,
      /(\d+)\s?[Cc]ount/,
      /(\d+)\s?[Cc][Tt]/,
      /(\d+)[\s-]?[Pp]ack($|[^e])/,
      /(\d+)\s?[Pp][Kk]/
  ].find {|regexp| size_info  =~ regexp}
  in_pack = match ? $1 : '1'


  is_available = product['isAvailable']==true ? "1":""
  image = "https:"+product['images']['list']["200"] rescue ''

  product_details = {
      # - - - - - - - - - - -
      RETAILER_ID: '121',
      RETAILER_NAME: 'bringmeister',
      GEOGRAPHY_NAME: 'DE',
      # - - - - - - - - - - -
      SCRAPE_INPUT_TYPE: page['vars']['input_type'],
      SCRAPE_INPUT_SEARCH_TERM: page['vars']['search_term'],
      SCRAPE_INPUT_CATEGORY: page['vars']['input_type'] == 'taxonomy' ? 'Energy' : '-',
      SCRAPE_URL_NBR_PRODUCTS: scrape_url_nbr_products,
      # - - - - - - - - - - -
      SCRAPE_URL_NBR_PROD_PG1: nbr_products_pg1,
      # - - - - - - - - - - -
      PRODUCT_BRAND: brand,
      PRODUCT_RANK: i+1,
      PRODUCT_PAGE: page['vars']['page'],
      PRODUCT_ID: product['id'],
      PRODUCT_NAME: product['name'],
      EAN: product['sku'],
      PRODUCT_DESCRIPTION: "",
      PRODUCT_MAIN_IMAGE_URL:image,
      PRODUCT_ITEM_SIZE: item_size,
      PRODUCT_ITEM_SIZE_UOM: uom,
      PRODUCT_ITEM_QTY_IN_PACK: in_pack,
      SALES_PRICE: price,
      IS_AVAILABLE: is_available,
      PROMOTION_TEXT: promotion,
      EXTRACTED_ON: Time.now.to_s
  }

  product_details['_collection'] = 'products'

  payload = '{"operationName":"GetProductDetails","variables":{"productId":"product_id","zip":"13355"},"query":"query GetProductDetails($productId: String!, $zip: String!) {\n  product(productId: $productId, zip: $zip) {\n    name\n    sku\n    isAvailable\n    depositType\n    images {\n      list\n      details\n      __typename\n    }\n    prices {\n      price\n      specialPrice\n      specialEndDateTs\n      specialStartDateTs\n      __typename\n    }\n    nutrition {\n      reference\n      items {\n        label\n        value\n        __typename\n      }\n      __typename\n    }\n    ingredients {\n      text\n      additives\n      allergenic\n      __typename\n    }\n    features {\n      label\n      value\n      __typename\n    }\n    content {\n      hint\n      description\n      __typename\n    }\n    __typename\n  }\n}\n"}'
  payload = payload.gsub(/product_id/,product['id'])
  pages << {
      page_type: 'product_description',
      method: 'POST',
      url: "https://www.bringmeister.de/graphql?search=#{page['vars']['search_term']}&ipage=#{page['vars']['page']}&irank=#{i + 1}",
      body:payload,
      vars: {
          'product_details' => product_details
      }

  }


end

