﻿using Equ;
using RBush;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Server
{
    public class Tile : MemberwiseEquatable<Tile>, ISpatialData
    {
        public uint TileId { get; }
        public Int2 GridPosition { get; }
        /// <summary>
        /// Number of clockwise 90 degree turns applied to this tile.
        /// </summary>
        public uint Rotation { get; }

        public TileType TileType => World.TileTypes[(int)TileId];

        private readonly Envelope _envelope;
        public ref readonly Envelope Envelope => ref _envelope;

        public Tile(uint tileId, Int2 gridPosition, uint rotation)
        {
            TileId = tileId;
            GridPosition = gridPosition;
            Rotation = rotation;

            // We add some margin to the envelope to rounding errors giving false collisions.
            _envelope = GetGridEnvelope(gridPosition, TileType.GridSize);
        }

        public static Envelope GetGridEnvelope(Int2 gridPosition, Int2 gridSize) => 
            new Envelope(
                gridPosition.X + 0.1,
                gridPosition.Y + 0.1,
                gridPosition.X + gridSize.X - 0.1,
                gridPosition.Y + gridSize.Y - 0.1);
    }
}
