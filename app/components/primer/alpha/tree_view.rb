# frozen_string_literal: true

# The TreeView component is made up of a number of smaller components, quite a few more than have been created
# to construct other components. The current architecture was designed to achieve reusability for certain
# features like loading indicators, different icons for expanded and collapsed sub trees, etc. The following
# describes how the components fit together at a high level, using React-like syntax. Each element in the
# diagram corresponds to one of three types of object:
#
# 1. Elements with TitleCase tags represent components in the Primer::Alpha::TreeView namespace, eg <LeafNode>.
# 2. Elements with dasherized-tags are web components/custom elements, eg <tree-view>.
# 3. Elements with lowercase tags are regular 'ol HTML elements, eg <ul>.
#
# ### Overall structure
#
# <TreeView>
#   <tree-view>
#     <ul role="tree">
#       <LeafNode>
#         <Node>
#           <li role="treeitem">
#             ...
#           </li>
#         </Node>
#       </LeafNode>
#
#       <SubTreeNode>
#         <tree-view-sub-tree-node>
#           <li role="treeitem">
#
#             <SubTreeContainer>
#               <ul role="group">
#                 <SubTree>
#                   <LeafNode>
#                     <Node>
#                       <li role="treeitem">
#                         ...
#                       </li>
#                     </Node>
#                   </LeafNode>
#
#                   <SubTreeNode>
#                     <tree-view-sub-tree-node>
#                       <Node>
#                         <li role="treeitem">
#                           ...
#                         </li>
#                       </Node>
#                       <SubTreeContainer>
#                         <ul role="group">
#                           ...
#                         </ul>
#                       </SubTreeContainer>
#                     </tree-view-sub-tree-node>
#                   </SubTreeNode>
#                 </SubTree>
#               </ul>
#             </SubTreeContainer>
#
#           </li>
#         </tree-view-sub-tree-node>
#       </SubTreeNode>
#     </ul>
#   </tree-view>
# </TreeView>
#
# ### Leading visuals
#
# TreeView nodes (i.e. both leaf and sub tree nodes) support leading and trailing visuals. At the time of this
# writing, only octicons are supported. The single icon case is achieved by using a standard slot, but the
# component also supports rendering distinct icons for both the expanded and collapsed states. An overview of the
# markup for this more complicated multi-icon feature is described below.
#
# <LeafNode>
#   <Node>
#     <li role="treeitem">
#       <Visual>
#         <IconPair>
#           <tree-view-icon-pair>
#             <Icon slot="expanded_icon">
#               <Primer::Beta::Octicon />
#             </Icon>
#             <Icon slot="collapsed_icon">
#               <Primer::Beta::Octicon />
#             </Icon>
#           </tree-view-icon-pair>
#         </IconPair>
#       </Visual>
#     </li>
#   </Node>
# </LeafNode>
#
# ### Loaders
#
# TreeViews support two types of loader: a loading spinner and a loading skeleton.
#
# #### Loading spinner
#
# <SubTree>
#   <SpinnerLoader>
#     <tree-view-include-fragment>
#       <SubTreeContainer>
#         <Node>
#           <Primer::Beta::Spinner />
#         </Node>
#         <Node>
#           <LoadingFailureMessage />
#         </Node>
#       </SubTreeContainer>
#     </tree-view-include-fragment>
#   </SpinnerLoader>
# </SubTree>
#
# #### Loading skeleton
#
# <SubTree>
#   <SkeletonLoader>
#     <tree-view-include-fragment>
#       <SubTreeContainer>
#         <Node>
#           <span>
#             <Primer::Alpha::SkeletonBox width="16px" />
#             <Primer::Alpha::SkeletonBox width="100%" />
#           </span>
#           <span>
#             ...
#           </span>
#           ...
#         </Node>
#         <Node>
#           <LoadingFailureMessage />
#         </Node>
#       </SubTreeContainer>
#     </tree-view-include-fragment>
#   </SkeletonLoader>
# </SubTree>

module Primer
  module Alpha
    # TreeView is a hierarchical list of items that may have a parent-child relationship where children
    # can be toggled into view by expanding or collapsing their parent item.
    class TreeView < Primer::Component
      renders_many :nodes, types: {
        leaf: {
          renders: lambda { |component_klass: LeafNode, label:, **system_arguments|
            component_klass.new(
              **system_arguments,
              path: [label],
              label: label
            )
          },

          as: :leaf
        },

        sub_tree: {
          renders: lambda { |component_klass: SubTreeNode, label:, **system_arguments|
            component_klass.new(
              **system_arguments,
              path: [label],
              label: label
            )
          },

          as: :sub_tree
        }
      }

      def initialize(**system_arguments)
        @system_arguments = deny_tag_argument(**system_arguments)

        @system_arguments[:tag] = :ul
        @system_arguments[:role] = :tree
        @system_arguments[:classes] = class_names(
          @system_arguments.delete(:classes),
          "TreeViewRootUlStyles"
        )
      end

      private

      def before_render
        if (first_node = nodes.first)
          first_node.merge_system_arguments!(tabindex: 0)
        end
      end
    end
  end
end
