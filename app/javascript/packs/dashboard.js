import * as dashboardWidget from 'Dashboard/ajax-widget'
import { initialize as tabsWidget } from 'Dashboard/tabs-widget'
import { ApiFilterWrapper as ApiFilter } from 'Dashboard/components/ApiFilter'
import { initialize as toggleWidget } from 'Dashboard/toggle'
import { render as renderChartWidget } from 'Dashboard/chart'

import { safeFromJsonString } from 'utilities/json-utils'

function renderApiFilter (id) {
  const { apis, domClass, placeholder } = document.getElementById(id).dataset

  ApiFilter({ apis: safeFromJsonString(apis), domClass, placeholder }, id)
}

document.addEventListener('DOMContentLoaded', () => {
  window.dashboardWidget = dashboardWidget
  window.toggleWidget = toggleWidget
  window.renderChartWidget = renderChartWidget

  tabsWidget()
  void ['products_search', 'backends_search'].forEach(renderApiFilter)
})
