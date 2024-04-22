
using api_app_notes.Model.Entity;
using Microsoft.EntityFrameworkCore;

namespace api_app_notes.Data
{
   
    public class DataContext : DbContext
    {
        public DataContext(DbContextOptions contextOptions) : base(contextOptions) { }
    
        public DbSet<UserClient> UserClient { get; set; }
        public DbSet<Notes> Notes { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        { 
             modelBuilder.Entity<Notes>()
                .HasOne(u => u.UserClient)
                .WithMany(u => u.Notes)
                .HasForeignKey(u => u.Email)
                .OnDelete(DeleteBehavior.NoAction);
        
        }
        }
}
