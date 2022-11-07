require 'json'
module REXMLInspector
  def to_debug_visualizer_protocol kw
    {
      "root": {
          "items": [
              {
                  "text": "CompilationUnit"
              }
          ],
          "isMarked": false,
          "data": {
              "position": 0,
              "length": 511
          },
          "children": [
              {
                  "items": [
                      {
                          "text": "UsingDirective"
                      }
                  ],
                  "isMarked": false,
                  "data": {
                      "position": 0,
                      "length": 13
                  },
                  "children": [
                      {
                          "items": [
                              {
                                  "text": "StaticKeyword",
                                  "emphasis": "style1"
                              },
                              {
                                  "text": ": IdentifierName"
                              },
                              {
                                  "text": "System",
                                  "emphasis": "style2"
                              }
                          ],
                          "isMarked": false,
                          "data": {
                              "position": 6,
                              "length": 6
                          },
                          "children": []
                      }
                  ]
              },
              {
                  "items": [
                      {
                          "text": "UsingDirective"
                      }
                  ],
                  "isMarked": false,
                  "data": {
                      "position": 15,
                      "length": 25
                  },
                  "children": [
                      {
                          "items": [
                              {
                                  "text": "StaticKeyword",
                                  "emphasis": "style1"
                              },
                              {
                                  "text": ": QualifiedName"
                              }
                          ],
                          "isMarked": false,
                          "data": {
                              "position": 21,
                              "length": 18
                          },
                          "children": [
                              {
                                  "items": [
                                      {
                                          "text": "Left",
                                          "emphasis": "style1"
                                      },
                                      {
                                          "text": ": IdentifierName"
                                      },
                                      {
                                          "text": "System",
                                          "emphasis": "style2"
                                      }
                                  ],
                                  "isMarked": false,
                                  "data": {
                                      "position": 21,
                                      "length": 6
                                  },
                                  "children": []
                              },
                              {
                                  "items": [
                                      {
                                          "text": "Right",
                                          "emphasis": "style1"
                                      },
                                      {
                                          "text": ": IdentifierName"
                                      },
                                      {
                                          "text": "Collections",
                                          "emphasis": "style2"
                                      }
                                  ],
                                  "isMarked": true,
                                  "data": {
                                      "position": 28,
                                      "length": 11
                                  },
                                  "children": []
                              }
                          ]
                      }
                  ]
              },
              {
                  "items": [
                      {
                          "text": "UsingDirective"
                      }
                  ],
                  "isMarked": false,
                  "data": {
                      "position": 42,
                      "length": 18
                  },
                  "children": [
                      {
                          "items": [
                              {
                                  "text": "StaticKeyword",
                                  "emphasis": "style1"
                              },
                              {
                                  "text": ": QualifiedName"
                              }
                          ],
                          "isMarked": false,
                          "data": {
                              "position": 48,
                              "length": 11
                          },
                          "children": [
                              {
                                  "items": [
                                      {
                                          "text": "Left",
                                          "emphasis": "style1"
                                      },
                                      {
                                          "text": ": IdentifierName"
                                      },
                                      {
                                          "text": "System",
                                          "emphasis": "style2"
                                      }
                                  ],
                                  "isMarked": false,
                                  "data": {
                                      "position": 48,
                                      "length": 6
                                  },
                                  "children": []
                              },
                              {
                                  "items": [
                                      {
                                          "text": "Right",
                                          "emphasis": "style1"
                                      },
                                      {
                                          "text": ": IdentifierName"
                                      },
                                      {
                                          "text": "Linq",
                                          "emphasis": "style2"
                                      }
                                  ],
                                  "isMarked": false,
                                  "data": {
                                      "position": 55,
                                      "length": 4
                                  },
                                  "children": []
                              }
                          ]
                      }
                  ]
              }
          ]
      },
      "kind": {
          "tree": true
      }
  }
  end

  def get_tree elems
    ary = []
    elems.each_element{|elem|
      hash = {}
      key = elem.name
      childs = []
      if elem.attributes.size > 0
        attrs = {}
        elem.attributes.each_attribute{|attribute|
          attrs[attribute.name] = attribute.value
        }
        childs << attrs
      end
      if elem.has_elements?
        childs.push *get_tree(elem)
      end
      if childs.size == 0
        hash[key] = elem.text
      else
        if elem.text && elem.text.strip != ""
          key = "#{key} #{elem.text}"
        end
        hash[key] = childs
      end
      ary << hash
    }
    ary
  end
end

begin
  require 'rexml'
  REXML::Document.prepend REXMLInspector
rescue LoadError
end

module ActiveRecordInspector
  def to_debug_visualizer_protocol kw
    ary = self.to_a
    table_data = ary[kw['offset'], kw['pageSize']].map{|elem| elem.attributes}
    x_keys = []
    y_keys = []
    table_data.first.each{|key, val|
      if key == 'id' || !val.is_a?(Numeric)
        x_keys << key
      else
        y_keys << key
      end
    }
    [
      {
        type: :table,
        data: table_data,
        paginate: {
          totalLen: ary.size
        }
      },
      {
        type: :barChart,
          data: table_data,
          xAxisKeys: x_keys,
          yAxisKeys: y_keys
      },
      {
        type: :lineChart,
          data: table_data,
          xAxisKeys: x_keys,
          yAxisKeys: y_keys
      }
    ]
  end
end

begin
  require 'active_support'
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Relation.include ActiveRecordInspector
  end
rescue LoadError
end

module ArrayInspector
  def to_debug_visualizer_protocol
    if self.all? {|v| v.is_a?(Integer) || v.is_a?(Float) }
      JSON.generate({
          "kind":{ "plotly": true },
          "data":[
              { "y": self },
          ]
        })
    end
  end
end

Array.prepend ArrayInspector
