require_relative './returns_http_status_code'
require_relative './returns_text_in_body'

RSpec.shared_examples 'fails validation' do |status_code, status_message, body_text|
  it('fails validation') { expect(subject).to_not be_ok }
  include_examples 'returns http status code', status_code, status_message
  include_examples 'returns text in body', body_text
end
