module PageHelper
  def within_current_modal(&block)
    within '.modal.in' do
      yield
    end
  end

  def open_hamburger_menu(&block)
    find('.navbar-toggler').click

    within '#hamburger-menu' do
      yield
    end
  end
end
