#!/usr/bin/env python3
# -----------------------------------------------------------------------------
# Simple script to plot Jaccard indices as a radial bar chart
# -----------------------------------------------------------------------------

import matplotlib
matplotlib.use("Agg") 
import numpy as np
import matplotlib.pyplot as plt
import argparse


def plot_jaccard_values(jaccard_values, names, output_path):
    
    """
    Plots a radial bar chart using jaccard values and category names.

    jaccard_values: list of numeric values.
    names: list of category names (same length as the data lists).
    """

    N = len(names)

    angles = np.linspace(0, 2 * np.pi, N, endpoint=False)
    max_value = np.max(jaccard_values)
    
    # Create a polar subplot
    fig, ax = plt.subplots(subplot_kw={'projection': 'polar'}, figsize=(8, 8))
    bar_width = (2 * np.pi / N) * 0.8

    # Plot the bars
    ax.bar(angles, jaccard_values, width=bar_width, bottom=0,
           color="#384C7F", alpha=0.8, label="Jaccard Index")

    # Adjust radial limits and grid
    ax.set_ylim(0, max_value * 1.1)
    ax.set_theta_zero_location("N")
    ax.set_theta_direction(-1)
    ax.xaxis.grid(True)
    ax.yaxis.grid(True)

    # Set category labels around the circle
    ax.set_xticks(angles)
    ax.set_xticklabels(names)
    ax.set_rlabel_position(0)
    ax.tick_params(axis="y", pad=-15)

    # Rotate labels for readability
    for label, angle in zip(ax.get_xticklabels(), angles):
        angle_deg = np.degrees(angle)
        if 90 <= angle_deg <= 270:
            label.set_rotation(180)
        label.set_horizontalalignment("center")

    # Title and legend
    ax.set_title("Radial Bar Chart for Jaccard", y=1.08)
    ax.legend(loc="lower right")

    plt.savefig(output_path)

def main():
    parser = argparse.ArgumentParser(
        description="Plot a radial stacked bar chart using two data series and category names."
    )
    parser.add_argument("--names", type=str, required=True,
                        help="Comma-separated list of category names.")
    parser.add_argument("--jaccard", type=str, required=True,
                        help="Comma-separated list of Jaccard values.")
    parser.add_argument("-o", "--out", type=str,
                        default="bed_intersect.png",
                        help="Path to save the output figure.")

    args = parser.parse_args()

    names = [name.strip() for name in args.names.split(",")]
    jaccard_values = [float(x.strip()) for x in args.jaccard.split(",")]

    # Ensure inputs align
    if len(names) != len(jaccard_values):
        raise ValueError("Length of names and jaccard values must match.")

    plot_jaccard_values(jaccard_values, names, args.out)

if __name__ == "__main__":
    main()
