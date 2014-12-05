class TabButton < UIButton

  def routesView=(rv)
    @routesView = WeakRef.new(rv)
  end

  def setup
    #puts "VIEWDID LOAD     TAB BUTTON"
    setImage( UIImage.imageNamed("tab_left.png"), forState: :normal.uistate)
    setImage( UIImage.imageNamed("tab_left_pressed.png"), forState: :selected.uistate)
    self.size = [64, 61]
    self.alpha = 0
    on(:touch) do
      #puts "TAB BUTTON TOUCHED!"
      @routesView.slide_in
    end
  end

  def slide_out
    @view_origin = origin
    animate(1.0) { self.alpha=0; self.origin = [self.origin.x + self.origin.x + self.size.width + 10, self.origin.y]}
    @view_is_out = true
  end

  def slide_in
    animate(1.0) { self.alpha=1; self.origin = @view_origin}
    @view_is_out = false
  end


end