const React = require('react');
const I18n = require('./common.i18n');

class Section extends React.Component {
  static defaultProps = {
    lastSection: false
  };

  onClickNext = (event) => {
    event.preventDefault();

    this.props.onClickNext(this.props.section);
  };

  render() {
    let { section, children, lastSection } = this.props,
      actionLabel;

    if (lastSection)
      actionLabel = 'Absenden';
    else
      actionLabel = 'Weiter';

    return (
      <section className="nodes-new-content-section">
        <h2><I18n scope={'nodes.new.form.section.' + section.key + '.title'}/></h2>
        <div className="nodes-new-content-section-form">
          {children}
        </div>
        <div className="form-actions">
          <button className="btn btn-primary pull-right submit" onClick={this.onClickNext}>{actionLabel}</button>
        </div>
      </section>
    );
  }
}

module.exports = Section;