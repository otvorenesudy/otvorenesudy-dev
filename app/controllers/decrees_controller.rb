class DecreesController < SearchController
  before_filter { flash_message_wrap keys: %i(danger warning) }

  def show
    @decree = Decree.find(params[:id])

    @court  = @decree.court
    @judges = @decree.judges.order(:last, :middle, :first)

    @legislations = @decree.legislations.order(:value)

    flash.now[:danger]  << render_to_string(partial: 'unprocessed',     locals: { decree: @decree }).html_safe if @decree.unprocessed?
    flash.now[:danger]  << render_to_string(partial: 'has_future_date', locals: { decree: @decree }).html_safe if @decree.has_future_date?
    flash.now[:warning] << render_to_string(partial: 'had_future_date', locals: { decree: @decree }).html_safe if @decree.had_future_date?
  end

  def resource
    @decree = Decree.find(params[:id])

    send_file_in @decree.resource_path, type: 'text/plain'
  end

  def document
    @decree = Decree.find(params[:id])

    return redirect_to @decree.pdf_uri if @decree.pdf_uri

    # TODO translate?
    send_file_in @decree.document_path, name: "Rozhodnutie-#{@decree.ecli}"
  end

  protected

  include FileHelper
  include FlashHelper

  private

  def search_associations
    # NOTE do not eager load scoped associations after original associations,
    # e.g. :exact_judges has to go before :judges, otherwise scoped association will not be loaded
    [:form, :legislation_area, :legislation_subarea, :natures, :court, :exact_judges, :inexact_judgements, :judgements, :judges]
  end
end
