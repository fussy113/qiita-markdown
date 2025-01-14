module Qiita
  module Markdown
    module Filters
      # Sanitizes undesirable elements by whitelist-based rule.
      # You can pass optional :rule and :script context.
      #
      # Since this filter is applied at the end of html-pipeline, it's rules
      # are intentionally weakened to allow elements and attributes which are
      # generated by other filters.
      #
      # @see Qiita::Markdown::Filters::UserInputSanitizerr
      class FinalSanitizer < HTML::Pipeline::Filter
        RULE = {
          attributes: {
            "a" => [
              "data-hovercard-target-name",
              "data-hovercard-target-type",
              "href",
              "rel",
            ],
            "blockquote" => Embed::Tweet::ATTRIBUTES,
            "iframe" => [
              "allowfullscreen",
              "frameborder",
              "height",
              "marginheight",
              "marginwidth",
              "scrolling",
              "src",
              "style",
              "width",
            ],
            "img" => [
              "src",
            ],
            "input" => [
              "checked",
              "disabled",
              "type",
            ],
            "div" => [
              "itemscope",
              "itemtype",
            ],
            "p" => Embed::CodePen::ATTRIBUTES,
            "script" => [
              "async",
              "src",
              "type",
            ].concat(
              Embed::SpeekerDeck::ATTRIBUTES,
              Embed::Docswell::ATTRIBUTES,
            ),
            "span" => [
              "style",
            ],
            "td" => [
              "style",
            ],
            "th" => [
              "style",
            ],
            "video" => [
              "src",
              "autoplay",
              "controls",
              "loop",
              "muted",
              "poster",
            ],
            all: [
              "abbr",
              "align",
              "alt",
              "border",
              "cellpadding",
              "cellspacing",
              "cite",
              "class",
              "color",
              "cols",
              "colspan",
              "data-lang",
              "datetime",
              "height",
              "hreflang",
              "id",
              "itemprop",
              "lang",
              "name",
              "rowspan",
              "tabindex",
              "target",
              "title",
              "width",
            ],
          },
          css: {
            properties: [
              "text-align",
              "background-color",
            ],
          },
          elements: [
            "a",
            "b",
            "blockquote",
            "br",
            "code",
            "dd",
            "del",
            "details",
            "div",
            "dl",
            "dt",
            "em",
            "font",
            "h1",
            "h2",
            "h3",
            "h4",
            "h5",
            "h6",
            "h7",
            "h8",
            "hr",
            "i",
            "img",
            "input",
            "ins",
            "kbd",
            "li",
            "ol",
            "p",
            "pre",
            "q",
            "rp",
            "rt",
            "ruby",
            "s",
            "samp",
            "script",
            "iframe",
            "span",
            "strike",
            "strong",
            "sub",
            "summary",
            "sup",
            "table",
            "tbody",
            "td",
            "tfoot",
            "th",
            "thead",
            "tr",
            "tt",
            "ul",
            "var",
          ],
          protocols: {
            "a" => {
              "href" => [
                :relative,
                "http",
                "https",
                "mailto",
              ],
            },
            "img" => {
              "src" => [
                :relative,
                "http",
                "https",
              ],
            },
            "video" => {
              "src" => [
                :relative,
                "http",
                "https",
              ],
              "poster" => [
                :relative,
                "http",
                "https",
              ],
            },
          },
          transformers: [
            Transformers::StripInvalidNode,
            Transformers::FilterScript,
            Transformers::FilterIframe,
          ],
        }.freeze

        SCRIPTABLE_RULE = RULE.dup.tap do |rule|
          rule[:attributes] = RULE[:attributes].dup
          rule[:attributes][:all] = rule[:attributes][:all] + [:data]
          rule[:elements] = RULE[:elements] + ["video"]
          rule[:transformers] = rule[:transformers] - [Transformers::FilterScript, Transformers::FilterIframe]
        end

        def call
          ::Sanitize.clean_node!(doc, rule)
          doc
        end

        private

        def has_script_context?
          context[:script] == true
        end

        def rule
          case
          when context[:rule]
            context[:rule]
          when has_script_context?
            SCRIPTABLE_RULE
          else
            RULE
          end
        end
      end
    end
  end
end
