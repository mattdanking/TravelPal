class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user! #, except: [:index, :show]
  respond_to :json


  # GET /expenses
  # GET /expenses.json
  def index
    @expenses = current_user.expenses.all
    @donut_data = current_user.donut_data(current_user.expenses.all)
    @bar_data = current_user.bar_data(current_user.expenses.all)
    @pink_data = current_user.pink_data(current_user.expenses.all)
    @spent = current_user.spent(current_user.expenses.all)

     @geojson = []
    
    @expenses.each do |m|
      if m.latitude 
        @geojson << {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [m.longitude, m.latitude]
          },
          properties: {
            id: m.id,
            :'marker-color' => '#00607d',
            :'marker-symbol' => 'circle',
            :'marker-size' => 'medium'
          }
        }

      end 
    end 


 # @expenses = Expense.by_recency
 #    @geojson = Expense.geojson

      respond_with(@expenses) do |format|
       @json = {"expenses" => @expenses.to_json(:only => [:latitude, :longitude])},
      #                   {"locations" => @expenses.to_json(:only => [:latitude, :longitude]
      format.json { render :json => @geojson } #NEW GEOJSON
      format.html
    end 
 



      # respond_with(@expenses) do |format|
      #  @json = {"expenses" => @expenses.to_json(:only => [:location, :cost])},
      #                   {"locations" => @expenses.to_json(:only => [:latitude, :longitude]
      # # format.json { render :json => @json }
      # format.html



    # render layout: "landingpage" #code added by Robert to force a particular view
  end
#NEW METHOD



  def tagged
    @tag = params[:tag]
    if params[:tag].present? 
      @expenses = current_user.expenses.tagged_with(params[:tag])
    else 
      @expenses = current_user.expenses.all
    end  
  end

  # GET /expenses/1
  # GET /expenses/1.json

  def show
  end

  # GET /expenses/new
  def new
    # @expense = Expense.new
    @expense = current_user.expenses.build
  end

  # GET /expenses/1/edit
  def edit
  end

  # POST /expenses
  # POST /expenses.json
  def create
    # @expense = Expense.new(expense_params)
    @expense = current_user.expenses.build(expense_params)

    respond_to do |format|
      if @expense.save
        format.html { redirect_to @expense, notice: 'Expense was successfully created.' }
        format.json { render :show, status: :created, location: @expense }
      else
        format.html { render :new }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /expenses/1
  # PATCH/PUT /expenses/1.json
  def update
    respond_to do |format|
      if @expense.update(expense_params)
        format.html { redirect_to @expense, notice: 'Expense was successfully updated.' }
        format.json { render :show, status: :ok, location: @expense }
      else
        format.html { render :edit }
        format.json { render json: @expense.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expenses/1
  # DELETE /expenses/1.json
  def destroy
    @expense.destroy
    respond_to do |format|
      format.html { redirect_to expenses_url, notice: 'Expense was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expense
      @expense = Expense.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expense_params
      params.require(:expense).permit(:textmsg, :cost, :date, :time, :location, :latitude, :longitude, :trip_id, :tag_list, :category)
    end


end
