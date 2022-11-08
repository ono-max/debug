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
  def to_debug_visualizer_protocol
    $stderr.puts :hogehoge
    rows = nil
    if self.respond_to? :to_a
      ary = self.to_a
      rows = ary.map{|elem| elem.attributes}
    else
      rows = [self.attributes]
    end
    
    JSON.generate({
        "kind": { "table": true },
        "rows": rows
    })
  end
end

begin
  require 'active_record'
  ActiveRecord::Base.include ActiveRecordInspector
  ActiveRecord::Relation.include ActiveRecordInspector
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
    else
      columns = []
      self.each{|elem|
        columns << {content: elem.to_s, tag: elem.to_s}
      }
      JSON.generate({
        "kind": { "grid": true },
        "text": "test",
        "columnLabels": [
            {
                "label": "test"
            }
        ],
        "rows": [
            {
                "label": "foo",
                "columns": columns
            }
        ]
      })
    end
  end
end

Array.prepend ArrayInspector

module HashInspector
  def to_debug_visualizer_protocol
    JSON.generate({
        "kind": { "table": true },
        "rows": [self]
    })
  end
end
  
Hash.prepend HashInspector  
