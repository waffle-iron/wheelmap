const React = require('react');
const { connect } = require('react-redux');

const Section = require('./Section');
const actions = require('../actions');
const { SIMILAR_NODES } = require('../models/sections');
const selectors = require('../selectors');
const Node = require('../../common/models/Node');
const { editNodePath } = require('../../common/routes');
const I18n = require('../../common/I18n');

const { func } = React.PropTypes;

class SimilarNodesSection extends React.Component {
  static propTypes = {
    onClickAction: func.isRequired
  };

  render() {
    let { similarNodes, loading, onClickAction } = this.props,
      items = [];

    similarNodes.forEach(node => {
      items.push(
        <li key={node.id}>
          <strong>{node.name}</strong> {node.address()}
          <a href={editNodePath(node.id)} className="pull-right"><I18n scope="nodes.new.form.section.similar_nodes.go_edit"/> <i className="icon-chevron-right"/></a>
        </li>
      );
    });

    return (
      <Section section={SIMILAR_NODES}
               actionExtraScope="nodes.new.form.section.similar_nodes.go_new"
               onClickAction={onClickAction}
               loading={loading}>
        <ul className="nodes-new-content-section--similar-list">
          {items}
        </ul>
      </Section>
    );
  }
}

function mapStateToProps(state) {
  return {
    node: selectors.node(state),
    similarNodes: selectors.similarNodes(state),
    loading: selectors.loading(state)
  };
}

function mapDispatchToProps(dispatch) {
  return {
    onClickAction: (section) => dispatch(actions.navigateToNextSection(section))
  };
}

module.exports = connect(
  mapStateToProps,
  mapDispatchToProps
)(SimilarNodesSection);