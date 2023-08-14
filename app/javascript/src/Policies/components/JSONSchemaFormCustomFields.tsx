/* eslint-disable react/jsx-curly-newline */
/* eslint-disable react/no-multi-comp */

// import TrashIcon from '@patternfly/react-icons/dist/js/icons/trash-icon'
import {
  Button,
  Checkbox,
  // FormFieldGroup,
  FormFieldGroupExpandable,
  FormFieldGroupHeader,
  FormGroup,
  FormSection,
  TextInput
} from '@patternfly/react-core'

import type { FunctionComponent } from 'react'
import type { FieldTemplateProps, ArrayFieldTemplateProps, FieldProps, ObjectFieldTemplateProps } from 'react-jsonschema-form'

const ArrayFieldTemplate: React.FunctionComponent<ArrayFieldTemplateProps> = (props) => {
  const { title, items, canAdd, onAddClick, idSchema } = props

  return (
    <FormFieldGroupExpandable
      isExpanded
      header={(
        <FormFieldGroupHeader
          actions={canAdd && (
            <Button variant="secondary" onClick={onAddClick}>Add parameter</Button>
          )}
          titleDescription=""
          titleText={{ text: title, id: idSchema.$id }}
        />
      )}
      toggleAriaLabel="Details"
    >
      {items.map(element => element.children)}
    </FormFieldGroupExpandable>
  )
}

const CustomObjectFieldTemplate: React.FunctionComponent<ObjectFieldTemplateProps> = (props) => {
  console.log({ props })

  return (
    <>
      {props.properties.map(element => element.content)}
    </>
  )
}

const CustomFieldTemplate: React.FunctionComponent<FieldTemplateProps> = (props) => {
  // const { id, classNames, label, help, required, description, errors, children } = props
  const { children } = props
  return children
}

const CustomTitleField: ArrayFieldTemplateProps['TitleField'] = ({ title, required }) => {
  const legend = required ? title + '*' : title
  return <FormSection title={legend} titleElement="h2" />
}

const CustomBooleanField: FunctionComponent<FieldProps<boolean>> = (props) => {
  const { formData, schema: { title }, idSchema, onChange } = props

  return (
    <FormGroup>
      <Checkbox
        id={idSchema.$id}
        isChecked={formData}
        label={title}
        onChange={checked => { onChange(checked) }}
      />
    </FormGroup>
  )
}

const CustomStringField: FunctionComponent<FieldProps<string>> = (props) => {
  const { formData, schema: { title }, idSchema, onChange, required } = props

  return (
    <FormGroup
      isRequired={required}
      label={title}
    >
      <TextInput
        id={idSchema.$id}
        isRequired={required}
        type="text"
        value={formData}
        onChange={value => { onChange(value) }}
      />
    </FormGroup>
  )
}

export {
  ArrayFieldTemplate,
  CustomBooleanField,
  CustomStringField,
  CustomFieldTemplate,
  CustomTitleField,
  CustomObjectFieldTemplate
}
