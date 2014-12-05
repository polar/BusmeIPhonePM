UIImage.class_eval do
  def flip(way)
    x_scale = way == :horizontal ? 1.0 : -1.0
    y_scale = way == :vertical ? -1.0 : 1.0

    return self.canvas(size: self.size) do |context|
      # Move the origin to the middle of the image so we will rotate and scale around the center.
      CGContextTranslateCTM(context, self.size.width / 2, self.size.height / 2)

      # otherwise it'll be upside down:
      CGContextScaleCTM(context, x_scale, y_scale)
      # Now, draw the rotated/scaled image into the context
      CGContextDrawImage(context, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), self.CGImage)
    end

  end
end