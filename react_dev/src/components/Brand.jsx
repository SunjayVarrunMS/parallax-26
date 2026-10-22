import { Link } from 'react-router-dom';
import { festival } from '../data.js';

// the logo link, used in the header and the footer
function Brand({ inverse }) {
  let className = 'brand';
  if (inverse) {
    className = 'brand brand--inverse';
  }
  return (
    <Link to="/" className={className} aria-label={festival.edition + ' home'}>
      <span className="brand__mark" aria-hidden="true">{festival.shortName}</span>
      <span>{festival.name}<span className="brand__year"> '26</span></span>
    </Link>
  );
}

export default Brand;
