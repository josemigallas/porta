import {
  Button,
  DataList,
  DataListAction,
  DataListCell,
  DataListControl,
  DataListDragButton,
  DataListItem,
  DataListItemCells,
  DataListItemRow,
  DragDrop,
  Draggable,
  Droppable,
  SearchInput,
  Toolbar,
  ToolbarContent,
  ToolbarItem
} from '@patternfly/react-core'
import PencilAltIcon from '@patternfly/react-icons/dist/js/icons/pencil-alt-icon'
import { useState } from 'react'
import escapeRegExp from 'lodash.escaperegexp'

import { PolicyTile } from 'Policies/components/PolicyTile'

import type { DraggableItemPosition } from '@patternfly/react-core'
import type { ChainPolicy, ThunkAction } from 'Policies/types'
import type { SortPolicyChainAction } from 'Policies/actions/PolicyChain'

interface Props {
  chain: ChainPolicy[];
  actions: {
    openPolicyRegistry: () => ThunkAction;
    editPolicy: (policy: ChainPolicy, index: number) => ThunkAction;
    sortPolicyChain: (policies: ChainPolicy[]) => SortPolicyChainAction;
  };
}

const PolicyChain: React.FunctionComponent<Props> = ({
  chain,
  actions
}) => {
  const [search, setSearch] = useState('')

  const isSearching = search !== ''

  const arrayMove = (list: ChainPolicy[], startIndex: number, endIndex: number): ChainPolicy[] => {
    const result = [...list]
    const [removed] = result.splice(startIndex, 1)
    result.splice(endIndex, 0, removed)
    return result
  }

  const onDrag = (): boolean => {
    return !isSearching
  }

  const onDrop = (source: DraggableItemPosition, dest?: DraggableItemPosition): boolean => {
    if (dest) {
      const sortedChain = arrayMove(chain, source.index, dest.index)
      actions.sortPolicyChain(sortedChain)
      return true
    } else {
      return false
    }
  }

  const handleOnSearch = (event: React.FormEvent<HTMLInputElement>, value: string) => {
    setSearch(value)
  }

  const term = new RegExp(escapeRegExp(search), 'i')
  const items = isSearching
    ? chain.filter(policy => term.test(policy.humanName))
    : chain

  return (
    <section>
      <Toolbar>
        <ToolbarContent>
          <ToolbarItem variant="search-filter">
            <SearchInput aria-label="Items example search input" onChange={handleOnSearch} />
          </ToolbarItem>
          <ToolbarItem>
            <Button variant="primary" onClick={actions.openPolicyRegistry}>Add policy</Button>
          </ToolbarItem>
        </ToolbarContent>
      </Toolbar>

      <DragDrop onDrag={onDrag} onDrop={onDrop}>
        <Droppable hasNoWrapper>
          <DataList isCompact aria-label="Policies list">
            {items.map((policy, index) => (
              <Draggable key={policy.uuid} hasNoWrapper>
                <DataListItem>
                  <DataListItemRow>
                    <DataListControl>
                      <DataListDragButton isDisabled={isSearching} />
                    </DataListControl>

                    <DataListItemCells
                      dataListCells={[
                        <DataListCell key={policy.uuid}>
                          <PolicyTile enabled={policy.enabled} policy={policy} />
                        </DataListCell>
                      ]}
                    />

                    <DataListAction
                      aria-label="Actions"
                      aria-labelledby={`policy-actions-${policy.uuid}`}
                      id={`policy-actions-${policy.uuid}`}
                    >
                      <Button
                        icon={<PencilAltIcon />}
                        title="Edit this Policy"
                        variant="link"
                        onClick={() => actions.editPolicy(policy, index)}
                      />
                    </DataListAction>
                  </DataListItemRow>
                </DataListItem>
              </Draggable>
            ))}
          </DataList>
        </Droppable>
      </DragDrop>
    </section>
  )
}

export type { Props }
export { PolicyChain }
