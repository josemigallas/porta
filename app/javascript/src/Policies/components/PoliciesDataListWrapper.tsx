import { Provider } from 'react-redux'

import PoliciesDataList from 'Policies/components/PoliciesDataList'
import configureStore from 'Policies/store/configureStore'
import { initialState } from 'Policies/reducers/initialState'
import { populateChainFromConfigs } from 'Policies/actions'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { Action, PolicyConfig, RegistryPolicy } from 'Policies/types'

interface Props {
  registry: RegistryPolicy[];
  chain: PolicyConfig[];
  serviceId: string;
}

const PoliciesDataListWrapper = ({ registry, chain, serviceId }: Props, elementId: string): void => {
  const store = configureStore(initialState)
  store.dispatch(populateChainFromConfigs(serviceId, chain, registry) as unknown as Action)

  createReactWrapper(
    <Provider store={store}>
      <PoliciesDataList />
    </Provider>,
    elementId
  )
}

export type { Props }
export { PoliciesDataListWrapper }
