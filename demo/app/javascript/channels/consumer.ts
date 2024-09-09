import {createConsumer} from '@rails/actioncable'

const consumer = createConsumer('ws://localhost:4000/cable')

export {consumer}
