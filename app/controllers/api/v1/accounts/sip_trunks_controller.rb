class Api::V1::Accounts::SipTrunksController < Api::V1::Accounts::BaseController
  before_action :check_authorization
  before_action :fetch_sip_trunks, only: [:index]
  before_action :fetch_sip_trunk, only: [:show, :update, :destroy]

  def index; end

  def show; end

  def create
    @sip_trunk = Current.account.sip_trunks.build(permitted_payload)
    if @sip_trunk.save
      render :show, status: :created
    else
      render json: { error: @sip_trunk.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    payload = permitted_payload
    payload.delete(:password) if payload[:password].blank?

    if @sip_trunk.update(payload)
      render :show, status: :ok
    else
      render json: { error: @sip_trunk.errors.messages }, status: :unprocessable_entity
    end
  end


  def destroy
    @sip_trunk.destroy!
    head :no_content
  end

  private

  def fetch_sip_trunks
    @sip_trunks = Current.account.sip_trunks.all
  end

  def fetch_sip_trunk
    @sip_trunk = Current.account.sip_trunks.find(params[:id])
  end

  def permitted_payload
    params.require(:sip_trunk).permit(
      :name,
      :server_host,
      :port,
      :transport,
      :username,
      :password,
      :outbound_caller_id,
      :is_default
    )
  end
end
