// We can define the 3scale plugins here and export the modified bundle
import SwaggerUI from 'swagger-ui'
import 'swagger-ui/dist/swagger-ui.css'

import { autocompleteOAS3 } from 'ActiveDocs/OAS3Autocomplete'

import 'ActiveDocs/swagger-ui-3-provider-patch.scss'

const accountDataUrl = '/p/admin/api_docs/account_data.json'

window.SwaggerUI = (args: SwaggerUI.SwaggerUIOptions, serviceEndpoint: string) => {
  const responseInterceptor = (response: SwaggerUI.Response) => autocompleteOAS3(response, accountDataUrl, serviceEndpoint)

  SwaggerUI({
    ...args,
    responseInterceptor
  } as SwaggerUI.SwaggerUIOptions)
}
