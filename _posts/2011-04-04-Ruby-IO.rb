---
layout: post
---
<tr id='section-1'>
  <td class=docs>
    <div class="pilwrap">
      <a class="pilcrow" href="#section-1">&#182;</a>
    </div>
    <p>Calling the data command and reading the output through a pipe.
Perhaps the simplest example of IO possible.</p>
  </td>
  <td class=code>
    <div class='highlight'><pre><span class="nb">puts</span> <span class="no">IO</span><span class="o">.</span><span class="n">popen</span><span class="p">(</span><span class="s1">&#39;date&#39;</span><span class="p">)</span><span class="o">.</span><span class="n">read</span>

<span class="no">IO</span><span class="o">.</span><span class="n">popen</span><span class="p">(</span><span class="s1">&#39;phone&#39;</span><span class="p">,</span> <span class="s1">&#39;w&#39;</span><span class="p">)</span> <span class="k">do</span> <span class="o">|</span><span class="n">f</span><span class="o">|</span>
    <span class="n">f</span><span class="o">.</span><span class="n">puts</span> <span class="s1">&#39;Hello from process &#39;</span> <span class="o">+</span> <span class="no">Process</span><span class="o">.</span><span class="n">pid</span><span class="o">.</span><span class="n">to_s</span>
<span class="k">end</span>

<span class="sx">%x{echo hello | phone}</span>
<span class="nb">p</span> <span class="sx">%x{date}</span>

<span class="n">width</span> <span class="o">=</span> <span class="mi">80</span>
<span class="n">height</span> <span class="o">=</span> <span class="mi">20</span>

<span class="n">length</span> <span class="o">=</span> <span class="mi">160</span>
<span class="n">fps</span> <span class="o">=</span> <span class="mi">30</span>

<span class="no">File</span><span class="o">.</span><span class="n">open</span><span class="p">(</span><span class="s2">&quot;/dev/ttys001&quot;</span><span class="p">,</span> <span class="s1">&#39;w&#39;</span><span class="p">)</span> <span class="k">do</span> <span class="o">|</span><span class="n">f</span><span class="o">|</span>
   </pre></div>
  </td>
</tr>
<tr id='section-2'>
  <td class=docs>
    <div class="pilwrap">
      <a class="pilcrow" href="#section-2">&#182;</a>
    </div>
    <p>begin animation block</p>

  </td>
  <td class=code>
    <div class='highlight'><pre>   <span class="n">row</span> <span class="o">=</span> <span class="mi">0</span>
   <span class="n">increment</span> <span class="o">=</span> <span class="mi">1</span>
   <span class="p">(</span><span class="mi">1</span><span class="o">.</span><span class="n">.length</span><span class="p">)</span><span class="o">.</span><span class="n">each</span> <span class="k">do</span> <span class="o">|</span><span class="n">i</span><span class="o">|</span>
      <span class="nb">sleep</span><span class="p">(</span><span class="mi">1</span><span class="o">.</span><span class="n">to_f</span><span class="o">/</span><span class="n">fps</span><span class="p">)</span>
      <span class="n">f</span><span class="o">.</span><span class="n">puts</span> <span class="s2">&quot;</span><span class="se">\e</span><span class="s2">[2J</span><span class="se">\e</span><span class="s2">[f&quot;</span> <span class="c1"># &quot;\033[2J&quot;</span>
      <span class="n">f</span><span class="o">.</span><span class="n">puts</span>  <span class="s2">&quot;&quot;</span> <span class="o">+</span> <span class="p">(</span><span class="s2">&quot;</span><span class="se">\n</span><span class="s2">&quot;</span> <span class="o">*</span> <span class="n">row</span><span class="p">)</span> <span class="o">+</span> <span class="p">(</span><span class="s2">&quot; &quot;</span> <span class="o">*</span> <span class="p">(</span><span class="n">i</span> <span class="o">%</span> <span class="n">width</span><span class="p">))</span> <span class="o">+</span> <span class="s2">&quot;o&quot;</span>
      
      <span class="n">row</span> <span class="o">+=</span> <span class="n">increment</span>
      <span class="k">if</span> <span class="n">row</span> <span class="o">&gt;</span> <span class="n">height</span>
          <span class="n">increment</span> <span class="o">=</span> <span class="o">-</span><span class="mi">1</span>
      <span class="k">elsif</span> <span class="n">row</span> <span class="o">&lt;</span> <span class="mi">1</span> 
          <span class="n">increment</span> <span class="o">=</span> <span class="mi">1</span>
      <span class="k">end</span>
    
   <span class="k">end</span>
   
<span class="k">end</span>

<span class="no">IO</span><span class="o">.</span><span class="n">popen</span><span class="p">(</span><span class="s1">&#39;irb&#39;</span><span class="p">,</span> <span class="s1">&#39;w&#39;</span><span class="p">)</span> <span class="k">do</span> <span class="o">|</span><span class="n">f</span><span class="o">|</span>
   <span class="n">f</span><span class="o">.</span><span class="n">puts</span> <span class="s2">&quot; IO.popen(&#39;irb&#39;, &#39;w&#39;) do |f|</span>
<span class="s2">       f.puts </span><span class="se">\&quot;</span><span class="s2">puts &#39;hello&#39;</span><span class="se">\&quot;</span><span class="s2"></span>
<span class="s2">    end&quot;</span>
<span class="k">end</span></pre></div>
  </td>
</tr>
