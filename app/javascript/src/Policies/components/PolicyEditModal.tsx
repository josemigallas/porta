import Form from 'react-jsonschema-form'
import {
  Button,
  Checkbox,
  Modal,
  Stack,
  StackItem
} from '@patternfly/react-core'

import { isNotApicastPolicy } from 'Policies/util'
import {
  ArrayFieldTemplate,
  CustomBooleanField,
  // CustomFieldTemplate,
  CustomObjectFieldTemplate,
  CustomStringField,
  CustomTitleField
} from 'Policies/components/JSONSchemaFormCustomFields'

import type { ThunkAction, ChainPolicy } from 'Policies/types'
import type { UpdatePolicyConfigAction } from 'Policies/actions/PolicyConfig'

interface Props {
  policy: ChainPolicy;
  actions: {
    submitPolicyConfig: (policy: ChainPolicy) => ThunkAction;
    removePolicyFromChain: (policy: ChainPolicy) => ThunkAction;
    closePolicyConfig: () => ThunkAction;
    updatePolicyConfig: (policy: ChainPolicy) => UpdatePolicyConfigAction;
  };
  isOpen: boolean;
}

const PolicyEditModal: React.FunctionComponent<Props> = ({
  policy,
  actions,
  isOpen
}) => {
  const { submitPolicyConfig, removePolicyFromChain, closePolicyConfig, updatePolicyConfig } = actions
  const { humanName, version, summary, description, enabled, configuration, data, removable } = policy

  const EDIT_POLICY_FORM = 'edit-policy-form'

  const onSubmit = (chainPolicy: ChainPolicy) => {
    return ({ formData, schema }: { formData: ChainPolicy['data']; schema: ChainPolicy['configuration'] }) => {
      submitPolicyConfig({ ...chainPolicy, configuration: schema, data: formData })
    }
  }
  const togglePolicy = (checked: boolean) => {
    updatePolicyConfig({ ...policy, enabled: checked })
  }
  const remove = () => removePolicyFromChain(policy)
  const cancel = () => closePolicyConfig()

  const isPolicyVisible = isNotApicastPolicy(policy)

  const modalActions = []

  if (isPolicyVisible) {
    modalActions.push(
      <Button
        key="confirm"
        type="submit"
        variant="primary"
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        onClick={() => { document.forms.namedItem(EDIT_POLICY_FORM)!.requestSubmit() }}
      >
        Update Policy
      </Button>,
      <Button
        key="cancel"
        variant="secondary"
        onClick={cancel}
      >
        Cancel
      </Button>
    )
  } else {
    modalActions.push(
      <Button
        key="close"
        variant="primary"
        onClick={cancel}
      >
        Close
      </Button>
    )
  }

  if (removable) {
    modalActions.push(
      <Button
        key="remove"
        variant="danger"
        onClick={remove}
      >
        Remove
      </Button>
    )
  }

  return (
    <Modal
      actions={modalActions}
      aria-label="Edit policy modal"
      id="policy-edit-modal"
      isOpen={isOpen}
      title={humanName}
      variant="large"
      onClose={cancel}
    >
      <Stack hasGutter>
        <StackItem>
          <div className="pf-c-content">
            <p>{`${version} - ${summary || ''}`}</p>
            <p>{description}</p>
          </div>
        </StackItem>
        {isPolicyVisible && (
          <StackItem>
            <Checkbox
              id="policy-enabled"
              isChecked={enabled}
              label="Enabled"
              name="policy-enabled"
              onChange={togglePolicy}
            />
          </StackItem>
        )}
        {isPolicyVisible && (
          <>
            <StackItem>
              <Form
                ArrayFieldTemplate={ArrayFieldTemplate}
                // FieldTemplate={CustomFieldTemplate}
                ObjectFieldTemplate={CustomObjectFieldTemplate}
                className="pf-c-form"
                // @ts-expect-error fffssafdfa
                fields={fields}
                formData={data}
                name={EDIT_POLICY_FORM}
                schema={configuration}
                onSubmit={onSubmit(policy)}
              >
                <span /> { /* Prevents rendering default submit */ }
              </Form>
            </StackItem>
            <StackItem>
              <Form
                className="pf-c-form"
                formData={data}
                name={EDIT_POLICY_FORM}
                schema={configuration}
                onSubmit={onSubmit(policy)}
              >
                <span /> { /* Prevents rendering default submit */ }
              </Form>
            </StackItem>
          </>
        )}
      </Stack>
    </Modal>
  )
}

const fields = {
  // eslint-disable-next-line @typescript-eslint/naming-convention
  'TitleField': CustomTitleField,
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/naming-convention
  'BooleanField': CustomBooleanField,
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment, @typescript-eslint/naming-convention
  'StringField': CustomStringField
}

export type { Props }
export { PolicyEditModal }
