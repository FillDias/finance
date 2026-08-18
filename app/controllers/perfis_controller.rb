class PerfisController < ApplicationController
  skip_before_action :exigir_perfil, only: [ :index, :selecionar ]

  def index
    @perfis = Perfil.order(:nome)
  end

  def selecionar
    session[:perfil_id] = Perfil.find(params[:id]).id
    redirect_to root_path
  end
end
