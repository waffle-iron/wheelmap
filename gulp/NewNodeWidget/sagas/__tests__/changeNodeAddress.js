jest.dontMock('../changeNodeAddress');

import { take, put } from 'redux-saga/effects';

import { CHANGE_NODE_ADDRESS, changeNode, updateMap, changeNodeAddress } from '../../actions';
import selectors from '../../selectors';
import Node from '../../../common/models/Node';

const changeNodeAddressSaga = require('../changeNodeAddress').default;

describe('changeNodeAddress', () => {
  const generator = changeNodeAddressSaga();

  it('updates map', () => {
    expect(generator.next().value)
      .toEqual(take(CHANGE_NODE_ADDRESS));

    const node = new Node(),
      action = changeNodeAddress(node);

    node.address.mockReturnValue('node address');

    expect(generator.next(action).value)
      .toEqual(put(changeNode(node)));

    expect(generator.next().value)
      .toEqual(put(updateMap(node.address())));

    expect(generator.next().done)
      .toBe(false);
  });
});