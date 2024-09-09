import {consumer} from '../channels/consumer'
import {ViewComponent, PrimerAlphaActionList} from 'vc.js/src/vcjs'
import morphdom from 'morphdom'
import type {Channel} from 'actioncable'

const pendingRequests: Map<string, [number, (value: string) => void, () => void]> = new Map()

const vcjsChannel = new Promise<Channel>(resolve => {
  consumer.subscriptions.create(
    {channel: 'VcjsChannel'},
    {
      connected() {
        resolve(this)
      },

      received(data) {
        if (pendingRequests.has(data.request_id)) {
          const [startTime, resolveRequest] = pendingRequests.get(data.request_id)!
          const endTime = Date.now()
          const elapsedMs = endTime - startTime
          // eslint-disable-next-line no-console
          console.log(`Request ${data.request_id} took ${elapsedMs}ms`)
          pendingRequests.delete(data.request_id)
          resolveRequest(data.payload)
        }
      },
    },
  )
})

const render = async (component: ViewComponent): Promise<string> => {
  const channel = await vcjsChannel
  const requestId = window.crypto.randomUUID()

  const promise = new Promise<string>((resolve, reject) => {
    pendingRequests.set(requestId, [Date.now(), resolve, reject])
  })

  channel.send({payload: component.serialize(), request_id: requestId})
  return promise
}

let count = 1

const update = async () => {
  const result = await render(
    PrimerAlphaActionList.create({}, component => {
      component.with_heading({title: 'Heading'})

      for (let i = 0; i < count; i++) {
        component.with_item({label: `Label ${i + 1}`}, item => {
          item.with_description({}, () => `Description ${i + 1}`)
        })
      }
    }),
  )

  morphdom(document.querySelector('.action-list-wrapper')!, result, {childrenOnly: true})
}

document.addEventListener('DOMContentLoaded', () => {
  update()
})

document.querySelector('.action-list-add-item-btn')?.addEventListener('click', async () => {
  count++
  update()
})
