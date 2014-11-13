module Orientation
  def device_landscape?(orientation)
    device_landscape_left?(orientation) || device_landscape_right?(orientation)
  end

  def device_portrait?(orientation)
    device_right_side_up?(orientation) || device_upside_down?(orientation)
  end

  def device_landscape_left?(orientation)
    orientation == UIDeviceOrientationLandscapeLeft
  end

  def device_landscape_right?(orientation)
    orientation == UIDeviceOrientationLandscapeRight
  end

  def device_right_side_up?(orientation)
    orientation == UIDeviceOrientationPortrait
  end

  def device_upside_down?(orientation)
    orientation == UIDeviceOrientationPortraitUpsideDown
  end

  def interface_landscape?(orientation)
    interface_landscape_left?(orientation) || interface_landscape_right?(orientation)
  end

  def interface_portrait?(orientation)
    interface_right_side_up?(orientation) || interface_upside_down?(orientation)
  end

  def interface_landscape_left?(orientation)
    orientation == UIInterfaceOrientationLandscapeLeft
  end

  def interface_landscape_right?(orientation)
    orientation == UIInterfaceOrientationLandscapeRight
  end

  def interface_right_side_up?(orientation)
    orientation == UIInterfaceOrientationPortrait
  end

  def interface_upside_down?(orientation)
    orientation == UIInterfaceOrientationPortraitUpsideDown
  end

  def device_orientation_names
    @device_orientations ||= {
        UIDeviceOrientationUnknown => "UIDeviceOrientationUnknown",
        UIDeviceOrientationPortrait => "UIDeviceOrientationPortrait",
        UIDeviceOrientationPortraitUpsideDown => "UIDeviceOrientationPortraitUpsideDown",
        UIDeviceOrientationLandscapeLeft => "UIDeviceOrientationLandscapeLeft",
        UIDeviceOrientationLandscapeRight => "UIDeviceOrientationLandscapeRight",
        UIDeviceOrientationFaceUp => "UIDeviceOrientationFaceUp",
        UIDeviceOrientationFaceDown => "UIDeviceOrientationFaceDown"
    }
  end
  def interface_orientation_names
    @interface_orientations ||= {
        UIInterfaceOrientationUnknown => "UIInterfaceOrientationUnknown",
        UIInterfaceOrientationPortrait => "UIInterfaceOrientationPortrait",
        UIInterfaceOrientationPortraitUpsideDown => "UIInterfaceOrientationPortraitUpsideDown",
        UIInterfaceOrientationLandscapeLeft => "UIInterfaceOrientationLandscapeLeft",
        UIInterfaceOrientationLandscapeRight => "UIInterfaceOrientationLandscapeRight"
    }
  end
end