json.array! @sip_trunks do |sip_trunk|
  json.partial! 'api/v1/models/sip_trunk', formats: [:json], resource: sip_trunk
end
