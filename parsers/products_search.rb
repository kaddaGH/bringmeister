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
  uom = $1
  item_size = $2

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
      PRODUCT_MAIN_IMAGE_URL:"https:"+product['images']['list']["200"],
      PRODUCT_ITEM_SIZE: item_size,
      PRODUCT_ITEM_SIZE_UOM: uom,
      PRODUCT_ITEM_QTY_IN_PACK: in_pack,
      SALES_PRICE: price,
      IS_AVAILABLE: is_available,
      PROMOTION_TEXT: promotion,
      EXTRACTED_ON: Time.now.to_s
  }

  product_details['_collection'] = 'products'

  outputs << product_details


end

