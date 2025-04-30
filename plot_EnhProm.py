#!/usr/bin/env python3

#Jaccard overlap values from EnhancersAndPromoters.sh analysis:
#Human promoter Jaccard overlap across tissues: 52.9503
#Mouse promoter Jaccard overlap across tissues: 66.2135
#Human enhancer Jaccard overlap across tissues: 21.6835
#Mouse enhancer Jaccard overlap across tissues: 40.2630
#Pancreas enhancer Jaccard overlap across species: 28.5773
#Ovary enhancer Jaccard overlap across species: 31.0703

import matplotlib.pyplot as plt
import os
base_dir = "/Users/Hursh/Desktop/enhancer_promoter_annotations"
output_dir = os.path.join(base_dir, "plots")

# Create output directory 
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Updated Jaccard overlap values from the EnhancersAndPromoters.sh script
human_promoter = 52.9503
mouse_promoter = 66.2135
human_enhancer = 21.6835
mouse_enhancer = 40.2630
pancreas_jaccard = 28.5773
ovary_jaccard = 31.0703

# Purple and teal color scheme asked ChatGPT
shared_color = '#9b59b6'  
unique_color = '#1abc9c' 

def create_bar_plot(shared_pct, title, filename, species, cross_species=False):
    unique_pct = 100 - min(shared_pct, 100)
    values = [shared_pct, unique_pct]
    
    if cross_species:
        labels = ['Shared between human and mouse', 'Unique to one species']
    else:
        labels = ['Shared between pancreas and ovary', f'Unique to {species} tissue']
    colors = [shared_color, unique_color]

    plt.figure()
    bars = plt.bar(labels, values, width=0.6, color=colors)
    for bar in bars:
        height = bar.get_height()
        plt.text(bar.get_x() + bar.get_width() / 2, height + 1, f'{height:.1f}%', ha='center', fontsize=12)
    plt.ylim(0, 110)
    plt.ylabel('Jaccard (%)', fontsize=12)
    plt.title(title, fontsize=14)
    full_path = os.path.join(output_dir, filename) #debug by ChatGPT
    plt.savefig(full_path)
    plt.close()
    

create_bar_plot(human_promoter, 'Human Promoter Conservation Between Pancreas and Ovary', 'human_promoter.png', 'human')
create_bar_plot(mouse_promoter, 'Mouse Promoter Conservation Between Pancreas and Ovary', 'mouse_promoter.png', 'mouse')
create_bar_plot(human_enhancer, 'Human Enhancer Conservation Between Pancreas and Ovary', 'human_enhancer.png', 'human')
create_bar_plot(mouse_enhancer, 'Mouse Enhancer Conservation Between Pancreas and Ovary', 'mouse_enhancer.png', 'mouse')
create_bar_plot(pancreas_jaccard, 'Pancreas Enhancer Conservation Between Human and Mouse', 'pancreas_cross_species.png', 'pancreas', cross_species=True)
create_bar_plot(ovary_jaccard, 'Ovary Enhancer Conservation Between Human and Mouse', 'ovary_cross_species.png', 'ovary', cross_species=True)

