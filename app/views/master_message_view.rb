class MasterMessageView < UIAlertView
  attr_accessor :masterMessage

  def self.forMasterMessage(msg)
    button_titles = []
    button_titles << "Go" if msg.goUrl
    button_titles << "Remind Me Later"
    view = UIAlertView.alloc.initWithTitle("Welcome to #{msg.title}",
                                                     message: msg.description,
                                                     delegate:nil,
                                                     cancelButtonTitle: "Cancel",
                                                     otherButtonTitles: button_titles)
    view
  end
end