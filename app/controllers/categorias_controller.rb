class CategoriasController < ApplicationController
  before_action :set_categoria, only: [ :edit, :update, :destroy ]

  def index
    @categoria = Categoria.new
    @categorias = Categoria.order(:nome)
  end

  def create
    resultado = CriarCategoria.call(**categoria_params)

    if resultado.sucesso?
      redirect_to categorias_path, notice: "Categoria criada."
    else
      @categoria = resultado.valor
      @categorias = Categoria.order(:nome)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    resultado = AtualizarCategoria.call(categoria: @categoria, **categoria_params)

    if resultado.sucesso?
      redirect_to categorias_path, notice: "Categoria atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    resultado = ExcluirCategoria.call(categoria: @categoria)

    if resultado.sucesso?
      redirect_to categorias_path, notice: "Categoria removida."
    else
      redirect_to categorias_path, alert: resultado.erros.join(", ")
    end
  end

  private

  def set_categoria
    @categoria = Categoria.find(params[:id])
  end

  def categoria_params
    params.require(:categoria).permit(:nome).to_h.symbolize_keys
  end
end
