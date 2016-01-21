const React = require('react');
const { createStore, applyMiddleware } = require('redux');
const thunk = require('redux-thunk');
const { Provider } = require('react-redux');
const { Router, Route, Redirect, browserHistory } = require('react-router');

const Widget = require('./nodes.widget_new');
const Content = require('./nodes.widget_new.content');
//const createStore = require('../helpers/create_store');
const reducer = require('../reducers/nodes.widget_new');
const { TRANSITION } = require('../reducers/common.router');
const { KEYS, NAME_CATEGORY } = require('../models/nodes.widget_new.section');

const { newNodePath, newNodeSectionPath } = global.Routes;

const createStoreWithMiddleware = applyMiddleware(thunk, transitionMiddleware)(createStore);

class App extends React.Component {
  constructor(props) {
    super(props);

    this.store = createStoreWithMiddleware(reducer);
  }

  componentDidMount() {
    // Connect router history with store
    /*this.historyListeners = this.history.listen(location => {
      this.store.dispatch(locationDidChange(location));
    });*/
  }

  componentWillUnmount() {
    // Stop listening to history.
    //this.historyListeners();
  }

  render() {
    return (
      <Provider store={this.store}>
        <Router ref="router" history={browserHistory}>
          <Redirect from={newNodePath.toString()} to={newNodeSectionPath(KEYS[NAME_CATEGORY])}/>
          <Route path={newNodePath.toString()} component={Widget}>
            <Route path={newNodeSectionPath.toString()} component={Content}/>
          </Route>
        </Router>
      </Provider>
    );
  }
}

function transitionMiddleware({ getState }) {
  return (next) => (action) => {
    let { type } = action;

    if (type !== TRANSITION)
      return next(action);

    let { payload: { method, args } } = action;

    browserHistory[method].apply(browserHistory, args);
  }
}

module.exports = App;