require 'cgi'
pages << {
    page_type: 'products_search',
    method: 'GET',
    url: 'https://www.bringmeister.de/api/products?browserUrl=getranke%2Feistee-sirup-energy%2Fenergy.html&limit=60&offset=0&sorting=default&zipcode=13355',
    vars: {
        'input_type' => 'taxonomy',
        'search_term' => '-',
        'page' => 1
    }


}

search_terms = ["Red Bull", "RedBull", "Energy Drink", "Energy Drinks"]
search_terms.each do |search_term|

  pages << {
      page_type: 'products_search',
      method: 'GET',
      url: "https://www.bringmeister.de/api/products?limit=60&offset=0&q=#{CGI.escape(search_term)}&sorting=default&zipcode=13355",
      vars: {
          'input_type' => 'search',
          'search_term' => search_term,
          'page' => 1
      }


  }

end