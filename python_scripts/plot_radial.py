#!/usr/bin/env python3

import matplotlib
matplotlib.use("Agg") 
import numpy as np
import matplotlib.pyplot as plt
import argparse


def plot_radial_stacked(data_A, data_B, names):
    
    """
    Plots a radial stacked bar chart using two data series (data_A and data_B)
    and a list of category names.

    data_A, data_B: lists of numeric values (same length).
    names: list of category names (same length as the data lists).
    """

    N = len(names)
    
    angles = np.linspace(0, 2 * np.pi, N, endpoint=False)

    stacked_values = np.array(data_A) + np.array(data_B)
    max_value = np.max(stacked_values)
    
    fig, ax = plt.subplots(subplot_kw={'projection': 'polar'}, figsize=(8, 8))

    bar_width = (2 * np.pi / N) * 0.8

    ax.bar(angles, data_A, width=bar_width, bottom=0,
           color="#BF4D4D", alpha=0.8, label="Data A")

    ax.bar(angles, data_B, width=bar_width, bottom=data_A,
           color="#384C7F", alpha=0.8, label="Data B")

    ax.set_ylim(0, max_value * 1.1)

    ax.set_theta_zero_location("N")
    ax.set_theta_direction(-1)

    ax.set_xticks(angles)
    ax.set_xticklabels(names)

    ax.xaxis.grid(True)
    ax.yaxis.grid(True)

    # Move radial labels outward if desired
    ax.set_rlabel_position(0)
    ax.tick_params(axis="y", pad=-15)

    for label, angle in zip(ax.get_xticklabels(), angles):
        angle_deg = np.degrees(angle)
        if 90 <= angle_deg <= 270:
            label.set_rotation(180)
        label.set_horizontalalignment("center")

    ax.set_title("Radial Stacked Bar Chart", y=1.08)
    ax.legend(loc="lower right")
    plt.savefig("bed_intersact.png")

def main():
    parser = argparse.ArgumentParser(
        description="Plot a radial stacked bar chart using two data series and category names."
    )
    parser.add_argument("--names", type=str, required=True,
                        help="Comma-separated list of category names.")
    parser.add_argument("--dataA", type=str, required=True,
                        help="Comma-separated list of numeric values for Data A.")
    parser.add_argument("--dataB", type=str, required=True,
                        help="Comma-separated list of numeric values for Data B.")

    args = parser.parse_args()

    names = [name.strip() for name in args.names.split(",")]
    data_A = [float(x.strip()) for x in args.dataA.split(",")]
    data_B = [float(x.strip()) for x in args.dataB.split(",")]

    if not (len(names) == len(data_A) == len(data_B)):
        raise ValueError("Length of names, dataA, and dataB must match.")

    plot_radial_stacked(data_A, data_B, names)

if __name__ == "__main__":
    main()
