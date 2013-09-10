#!/usr/bin/env python

class TreeNode:
  def __init__(self, parent, data):
    self._children = []
    self.parent = parent
    self.data = data
  
  def add_child(self, node):
    node.parent = self
    self._children.append(node)
  
  def compare_similar(self, node):
    if len(self._children) != len(node._children): return False
    if self.data != node.data: return False
    
    for one in self._children:
      matched = 0
      for two in node._children:
        if one.compare_similar(two): matched += 1
      
      if matched == 0: return False
    
    return True

def main():
  g1 = TreeNode(None,1)
  g2 = TreeNode(None,2)
  g3 = TreeNode(None,3)
  g4 = TreeNode(None,4)
  
  h1 = TreeNode(None,1)
  h2 = TreeNode(None,2)
  h3 = TreeNode(None,3)
  h4 = TreeNode(None,4)

  i1 = TreeNode(None,1)
  i2 = TreeNode(None,2)
  i3 = TreeNode(None,3)

  g1.add_child(g2)
  g2.add_child(g3)
  g2.add_child(g4)
  
  h1.add_child(h2)
  h2.add_child(h3)
  h2.add_child(h4)

  i1.add_child(i2)
  i2.add_child(i3)
  
  if g1.compare_similar(h1):
    print 'Totally similar'
  else:
    print 'Not at all similar'

  if g1.compare_similar(i1):
    print 'Totally similar'
  else:
    print 'Not at all similar'

if __name__ == '__main__': main()
