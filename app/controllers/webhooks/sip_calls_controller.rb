# frozen_string_literal: true

class Webhooks::SipCallsController < ActionController::API
  def process_payload
    event = params[:event]
    call_id = params[:call_id]
    from = params[:from]
    to = params[:to]
    direction = params[:direction] || 'incoming'

    case event
    when 'ringing'
      if direction == 'incoming'
        channel = Channel::SipCall.find_by(phone_number: to)
        if channel
          Voice::InboundCallBuilder.perform!(
            inbox: channel.inbox,
            from_number: from,
            call_sid: call_id,
            provider: :sip
          )
        end
      end
    when 'answered'
      call = Call.find_by_provider_call_id(:sip, call_id)
      if call
        call.update!(status: 'in_progress', started_at: Time.zone.now)
        # Notify the UI clients
        call.message&.touch
      end
    when 'completed'
      call = Call.find_by_provider_call_id(:sip, call_id)
      if call
        duration = params[:duration_seconds]&.to_i || 0
        call.update!(status: 'completed', duration_seconds: duration, ended_at: Time.zone.now)

        if params[:recording_url].present?
          SafeFetch.fetch(params[:recording_url], allowed_content_type_prefixes: %w[audio/]) do |result|
            call.recording.attach(
              io: result.tempfile,
              filename: "sip-call-#{call_id}.wav",
              content_type: result.content_type || 'audio/wav'
            )
          end
        end

        call.message&.touch
      end
    end

    head :ok
  rescue StandardError => e
    Rails.logger.error("SIP Webhook Error: #{e.message}")
    head :ok
  end
end
