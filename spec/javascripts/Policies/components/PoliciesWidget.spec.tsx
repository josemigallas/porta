
import { mount } from 'enzyme'

import { PoliciesDataList } from 'Policies/components/PoliciesDataList'

import type { Props } from 'Policies/components/PoliciesDataList'

it.todo('test PolicyWidget')

it('should render PolicyList', () => {
  const props: Props = {
    registry: [],
    chain: [],
    originalChain: [],
    policyConfig: {
      $schema: '$schema',
      configuration: {},
      description: [],
      name: 'human',
      summary: 'summary',
      version: '1',
      humanName: 'mr. human'
    },
    ui: {},
    boundActionCreators: {}
  } as any

  const wrapper = mount(<PoliciesDataList {...props} />)
  expect(wrapper.exists()).toEqual(true)
})
