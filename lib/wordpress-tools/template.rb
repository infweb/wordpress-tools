class Wordpress::Tools::Template
  def initialize(template, params={})
    @params = params
    @template = template
    metaclass = class <<self; self; end


    params.each do |k, v|
      metaclass.send(:define_method, k) { v }
    end
  end

  def render
    ERB.new(@template).result(binding)
  end
end