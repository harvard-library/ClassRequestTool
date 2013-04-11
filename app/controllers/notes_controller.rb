class NotesController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @notes = Note.find(:all, :order => :name)
  end  
  
  def new
    @note = Note.new
  end
  
  def edit
    @note = Note.find(params[:id])
  end
  
  def create
    @note = Note.new(params[:note])
    respond_to do |format|
      if @note.save
        format.html { redirect_to course_url(@note.course), notice: 'Note was successfully created.' }
        format.json { render json: @note, status: :created, note: @note }
      else
        format.html { render action: "new" }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @note = Note.find(params[:id])

    respond_to do |format|
      if @note.update_attributes(params[:note])
        format.html { redirect_to notes_url, notice: 'Note was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to notes_url }
      format.json { head :no_content }
    end
  end
end
