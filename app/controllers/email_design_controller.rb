class EmailDesignController < ApplicationController
    layout false
    def show
        render template: "email_design/#{params[:page]}"
    end
end
