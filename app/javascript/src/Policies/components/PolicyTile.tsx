import type { RegistryPolicy } from 'Policies/types'

interface Props {
  enabled: boolean;
  policy: RegistryPolicy;
}

const PolicyTile: React.FunctionComponent<Props> = ({
  enabled,
  policy
}) => (
  <div className={enabled ? '' : 'Policy--disabled'}>
    <h3>{policy.humanName}</h3>
    <p>{`${policy.version} - ${policy.summary || ''}`}</p>
  </div>
)

export type { Props }
export { PolicyTile }
