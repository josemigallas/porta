import {
  CardHeader,
  CardActions,
  Button,
  CardTitle,
  CardBody
} from '@patternfly/react-core'
import TimesIcon from '@patternfly/react-icons/dist/js/icons/times-icon'

import { isNotApicastPolicy } from 'Policies/util'
import { PolicyTile } from 'Policies/components/PolicyTile'

import type { RegistryPolicy, ThunkAction } from 'Policies/types'

interface Props {
  items: RegistryPolicy[];
  actions: {
    addPolicy: (policy: RegistryPolicy) => ThunkAction;
    closePolicyRegistry: () => ThunkAction;
  };
}

const PolicyRegistry: React.FunctionComponent<Props> = ({
  items,
  actions: { addPolicy, closePolicyRegistry }
}) => (
  <section className="PolicyRegistry">
    <CardHeader>
      <CardActions>
        <Button icon={<TimesIcon />} variant="link" onClick={closePolicyRegistry}>
            Cancel
        </Button>
      </CardActions>
      <CardTitle>
          Select a policy
      </CardTitle>
    </CardHeader>
    <CardBody>
      <ul className="list-group">
        {items.filter(isNotApicastPolicy).map(p => (
          <li key={p.name} className="Policy" onClick={() => addPolicy(p)}>
            <PolicyTile policy={p} title="Add this Policy" />
          </li>
        ))}
      </ul>
    </CardBody>
  </section>
)

export type { Props }
export { PolicyRegistry }
