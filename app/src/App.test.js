import { render, screen } from '@testing-library/react';
import App from './App';

test('renders environment variables section', () => {
  render(<App />);
  const header = screen.getByText(/environment variables/i);
  expect(header).toBeInTheDocument();
});
